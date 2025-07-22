#!/bin/bash

# upKep AI Prompt Generator
# Generates contextual AI prompts for module development based on state reflection

# Generate AI prompt for module creation
generate_ai_prompt() {
    local module_name="$1"
    local description="$2"
    local category="${3:-system_maintenance}"
    
    # Read current state for context
    local state_file="$HOME/.upkep/state.json"
    local modules=""
    local patterns=""
    local similar_module=""
    
    if [[ -f "$state_file" ]]; then
        if command -v jq >/dev/null 2>&1; then
            modules=$(jq -r '.modules | keys[]' "$state_file" 2>/dev/null)
            patterns=$(jq -r '.patterns | to_entries[] | "\(.key): \(.value)"' "$state_file" 2>/dev/null)
            similar_module=$(find_similar_module "$category" "$description")
        fi
    fi
    
    # Generate contextual prompt
    local prompt_file="prompt_for_${module_name}.txt"
    
    cat > "$prompt_file" << EOF
# upKep Module Creation Prompt
# Generated: $(date)
# Module: $module_name
# Category: $category

## Project Context
This upKep project manages Linux system maintenance with the following characteristics:

### Available Modules:
$(echo "$modules" | sed 's/^/- /')

### Common Patterns:
$(echo "$patterns" | sed 's/^/- /')

EOF

    if [[ -n "$similar_module" && -f "$state_file" ]]; then
        if command -v jq >/dev/null 2>&1; then
            local example_module=$(jq -r ".modules.$similar_module" "$state_file" 2>/dev/null)
            if [[ -n "$example_module" ]]; then
                cat >> "$prompt_file" << EOF
### Example Module Structure ($similar_module):
$(jq -r ".modules.$similar_module | to_entries[] | \"\(.key): \(.value)\"" "$state_file" 2>/dev/null | sed 's/^/- /')
EOF
            fi
        fi
    fi

    cat >> "$prompt_file" << EOF

## Module Requirements
Create a new upKep module named "$module_name" that:
- Description: $description
- Category: $category
- Follows the established patterns and conventions
- Integrates seamlessly with existing modules

## Required Functions
The module must implement these functions:
1. run_${module_name}() - Main execution function
2. get_${module_name}_status() - Status reporting (optional)
3. validate_${module_name}_environment() - Environment validation (optional)

## Required Variables
The module must set these status variables:
- ${module_name^^}_STATUS="success" or "failed" or "skipped"
- ${module_name^^}_MESSAGE="Human readable status message"
- ${module_name^^}_ERROR="Error details if failed" (optional)

## State Management
If the module updates system state, call:
- update_${module_name}_state() (create this function)

## Error Handling
Follow the established pattern:
if [[ \$? -eq 0 ]]; then
    ${module_name^^}_STATUS="success"
    update_${module_name}_state
else
    ${module_name^^}_STATUS="failed"
    ${module_name^^}_ERROR="Error description"
fi

## Progress Indicators
Use the spinner function for long operations:
(spinner \$! "Operation description") &

## Output Format
Please provide:
1. Complete module script (${module_name}.sh)
2. Module metadata (module.json)
3. Brief usage examples
4. Any dependencies or requirements

## Integration Notes
- The module will be loaded dynamically at runtime
- It should work with existing flags (--dry-run, --force, --verbose)
- Follow the same visual formatting patterns as other modules
- Include appropriate error handling and logging

## Code Style Guidelines
- Use consistent indentation (2 spaces)
- Include descriptive comments
- Follow bash best practices
- Use local variables where appropriate
- Handle errors gracefully
- Provide meaningful status messages

## Testing Considerations
- Include validation for required dependencies
- Test error conditions
- Verify status variable updates
- Check integration with state management
EOF

    echo "AI prompt generated: $prompt_file"
    echo "You can copy this prompt to your preferred AI tool for module generation."
}

# Find similar modules for examples
find_similar_module() {
    local category="$1"
    local description="$2"
    
    # Find modules in the same category
    local similar_modules=""
    
    if [[ -f "$HOME/.upkep/state.json" ]] && command -v jq >/dev/null 2>&1; then
        similar_modules=$(jq -r ".modules | to_entries[] | select(.value.category == \"$category\") | .key" "$HOME/.upkep/state.json" 2>/dev/null)
    fi
    
    # Return the first available module as example
    echo "$similar_modules" | head -n1
}

# Generate prompt for module improvement
generate_improvement_prompt() {
    local module_name="$1"
    local improvement_type="$2"
    
    local prompt_file="improvement_prompt_for_${module_name}.txt"
    
    cat > "$prompt_file" << EOF
# upKep Module Improvement Prompt
# Generated: $(date)
# Module: $module_name
# Improvement Type: $improvement_type

## Current Module Context
The module "$module_name" needs improvement in the area of "$improvement_type".

## Improvement Requirements
Please provide improvements for the following aspects:

EOF

    case "$improvement_type" in
        "error_handling")
            cat >> "$prompt_file" << EOF
### Error Handling Improvements
- Add comprehensive error checking
- Implement graceful error recovery
- Provide detailed error messages
- Handle edge cases and failure modes
- Add logging for debugging
EOF
            ;;
        "performance")
            cat >> "$prompt_file" << EOF
### Performance Improvements
- Optimize execution time
- Reduce resource usage
- Implement caching where appropriate
- Add progress indicators
- Minimize system impact
EOF
            ;;
        "security")
            cat >> "$prompt_file" << EOF
### Security Improvements
- Validate all inputs
- Sanitize user data
- Check file permissions
- Implement secure defaults
- Add security logging
EOF
            ;;
        "usability")
            cat >> "$prompt_file" << EOF
### Usability Improvements
- Improve user feedback
- Add configuration options
- Enhance status reporting
- Provide better documentation
- Add interactive features
EOF
            ;;
        *)
            cat >> "$prompt_file" << EOF
### General Improvements
- Review and optimize code
- Add missing functionality
- Improve error handling
- Enhance user experience
- Update documentation
EOF
            ;;
    esac

    cat >> "$prompt_file" << EOF

## Expected Output
Please provide:
1. Updated module code with improvements
2. Explanation of changes made
3. Testing recommendations
4. Any new dependencies or requirements

## Code Quality Standards
- Follow bash best practices
- Maintain backward compatibility
- Include appropriate comments
- Add error handling
- Test thoroughly
EOF

    echo "Improvement prompt generated: $prompt_file"
}

# Generate prompt for module testing
generate_testing_prompt() {
    local module_name="$1"
    
    local prompt_file="testing_prompt_for_${module_name}.txt"
    
    cat > "$prompt_file" << EOF
# upKep Module Testing Prompt
# Generated: $(date)
# Module: $module_name

## Testing Requirements
Create comprehensive tests for the "$module_name" module.

## Test Categories
1. **Unit Tests**
   - Test individual functions
   - Verify status variable updates
   - Check error handling
   - Validate input processing

2. **Integration Tests**
   - Test module interaction with state management
   - Verify configuration handling
   - Check logging functionality
   - Test with different environments

3. **Functional Tests**
   - Test complete module execution
   - Verify expected outcomes
   - Check error conditions
   - Test edge cases

## Test Framework
Use the existing upKep test framework:
- Test files: tests/test_cases/test_${module_name}.sh
- Mock support: tests/mocks/
- Test runner: tests/test_runner.sh

## Test Structure
Each test should:
- Have a descriptive name
- Set up test environment
- Execute test logic
- Verify results
- Clean up after execution

## Expected Output
Please provide:
1. Complete test file (test_${module_name}.sh)
2. Any required mock files
3. Test data and fixtures
4. Testing instructions
5. Coverage analysis

## Testing Best Practices
- Test both success and failure scenarios
- Use descriptive test names
- Include setup and teardown
- Mock external dependencies
- Verify state changes
- Test error conditions
EOF

    echo "Testing prompt generated: $prompt_file"
}

# Generate prompt for documentation
generate_documentation_prompt() {
    local module_name="$1"
    
    local prompt_file="documentation_prompt_for_${module_name}.txt"
    
    cat > "$prompt_file" << EOF
# upKep Module Documentation Prompt
# Generated: $(date)
# Module: $module_name

## Documentation Requirements
Create comprehensive documentation for the "$module_name" module.

## Documentation Sections
1. **Overview**
   - Module purpose and functionality
   - Key features and capabilities
   - Use cases and scenarios

2. **Installation and Setup**
   - Prerequisites and dependencies
   - Installation instructions
   - Configuration requirements
   - Environment setup

3. **Usage**
   - Command-line usage
   - Configuration options
   - Examples and use cases
   - Common scenarios

4. **API Reference**
   - Function documentation
   - Parameter descriptions
   - Return values
   - Error handling

5. **Configuration**
   - Configuration file format
   - Available options
   - Default values
   - Environment variables

6. **Troubleshooting**
   - Common issues and solutions
   - Error messages and meanings
   - Debugging tips
   - Support resources

## Documentation Format
- Use Markdown format
- Include code examples
- Add screenshots if relevant
- Provide clear structure
- Use consistent terminology

## Expected Output
Please provide:
1. Complete documentation file (${module_name}.md)
2. Code examples and snippets
3. Configuration examples
4. Troubleshooting guide
5. FAQ section

## Documentation Standards
- Clear and concise writing
- Consistent formatting
- Accurate information
- Up-to-date examples
- User-friendly language
EOF

    echo "Documentation prompt generated: $prompt_file"
}

# Generate comprehensive development prompt
generate_development_prompt() {
    local module_name="$1"
    local description="$2"
    local category="$3"
    local include_tests="${4:-true}"
    local include_docs="${5:-true}"
    
    local prompt_file="development_prompt_for_${module_name}.txt"
    
    cat > "$prompt_file" << EOF
# upKep Complete Module Development Prompt
# Generated: $(date)
# Module: $module_name
# Category: $category

## Project Overview
Create a complete upKep module including implementation, tests, and documentation.

## Module Requirements
- Name: $module_name
- Description: $description
- Category: $category
- Full implementation with error handling
- Comprehensive testing
- Complete documentation

## Implementation Requirements
1. **Core Module** (${module_name}.sh)
   - Main execution function
   - Status reporting
   - Environment validation
   - Error handling
   - State management integration

2. **Configuration** (module.json)
   - Module metadata
   - Dependencies
   - Configuration options
   - Requirements

3. **Tests** (test_${module_name}.sh)
   - Unit tests
   - Integration tests
   - Error condition tests
   - Mock implementations

4. **Documentation** (${module_name}.md)
   - Usage instructions
   - Configuration guide
   - Examples
   - Troubleshooting

## Development Standards
- Follow upKep conventions
- Use bash best practices
- Include comprehensive error handling
- Provide clear documentation
- Write thorough tests
- Maintain backward compatibility

## Expected Deliverables
1. Module implementation file
2. Module metadata file
3. Test suite
4. Documentation
5. Examples and usage guide
6. Configuration templates

## Quality Requirements
- Production-ready code
- Comprehensive testing
- Clear documentation
- Error handling
- Performance considerations
- Security best practices
EOF

    echo "Complete development prompt generated: $prompt_file"
}

# Main function to handle different prompt types
main_prompt_generator() {
    local prompt_type="$1"
    shift
    
    case "$prompt_type" in
        "create")
            generate_ai_prompt "$@"
            ;;
        "improve")
            generate_improvement_prompt "$@"
            ;;
        "test")
            generate_testing_prompt "$@"
            ;;
        "document")
            generate_documentation_prompt "$@"
            ;;
        "develop")
            generate_development_prompt "$@"
            ;;
        *)
            echo "Usage: $0 <type> [options]"
            echo "Types: create, improve, test, document, develop"
            echo "Examples:"
            echo "  $0 create my-module 'Description' category"
            echo "  $0 improve my-module error_handling"
            echo "  $0 test my-module"
            echo "  $0 document my-module"
            echo "  $0 develop my-module 'Description' category"
            return 1
            ;;
    esac
}

# If script is run directly, execute main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_prompt_generator "$@"
fi 