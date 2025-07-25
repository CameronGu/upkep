# upKep Task Execution Prompt

Use this prompt when beginning work on any upkep task to ensure quality and consistency.

---

## Pre-Implementation Analysis

Before implementing any feature or change, evaluate:

### 1. **Task Justification & User Value**
- **Does this solve a real problem for Linux users doing system maintenance?**
- **Is this the simplest solution that achieves the goal?**
- **Will this add meaningful value without bloating the codebase?**

If the answer to any question is "no" or unclear, **stop and reconsider the approach**.

### 2. **Project Principles Alignment**
Ensure your implementation follows upkep's core principles:

- ✅ **Simplicity**: Prefer straightforward solutions over clever ones
- ✅ **Maintainability**: Code should be easy to read, understand, and modify
- ✅ **Reliability**: Minimize potential failure points and edge cases
- ✅ **User Experience**: Focus on what users actually need in their daily workflows
- ✅ **Modularity**: Changes should integrate cleanly with existing architecture

### 3. **Target User Context**
upkep serves Linux users who:
- Run personal/development machines (not enterprise deployments)
- Want automated system maintenance without complexity
- Need occasional debugging/customization capabilities
- Value reliability over advanced features

**Ask**: Does this change serve these users' actual needs?

---

## Implementation Requirements

### Test-Driven Development
1. **Before coding**: Identify what needs testing
2. **Write tests first** when possible, or immediately after implementation
3. **Ensure comprehensive coverage**:
   - Happy path functionality
   - Error conditions and edge cases
   - Integration with existing components
   - Backward compatibility

### Testing Standards
- Add new test files to `tests/test_cases/`
- Update `tests/test_runner.sh` if adding new test files
- Follow existing test patterns and naming conventions
- Include both unit tests and integration tests where appropriate
- Test files should be self-contained and not depend on external state

### Code Quality
- Follow existing code patterns and style
- Add appropriate error handling
- Include helpful comments for complex logic
- Ensure backward compatibility unless explicitly breaking changes are needed

---

## Post-Implementation Verification

### Mandatory Final Steps

1. **Run Complete Test Suite**:
   ```bash
   ./tests/test_runner.sh
   ```
   
2. **Verify 100% Pass Rate**:
   - All tests must pass before considering task complete
   - If any tests fail, fix issues before proceeding
   - Address any new test failures introduced by your changes

3. **Integration Check**:
   - Test the actual user workflow your changes affect
   - Verify backward compatibility with existing configurations
   - Check that error messages are helpful to users

### Documentation Updates
Update documentation if your changes affect:
- User-facing commands or options
- Configuration format or options
- Installation or setup procedures
- Error messages or troubleshooting

---

## Success Criteria

A task is complete when:

- ✅ Solves the stated problem simply and effectively
- ✅ Maintains or improves code quality and maintainability  
- ✅ Has comprehensive test coverage
- ✅ Passes 100% of test suite
- ✅ Integrates seamlessly with existing functionality
- ✅ Provides clear value to target users
- ✅ Documentation is updated as needed

---

## Task-Specific Application

**For this specific task**: [Insert specific task details and considerations]

**Key Questions to Answer**:
1. What specific user problem does this solve?
2. What is the simplest implementation approach?
3. What could go wrong and how do we test for it?
4. Does this maintain backward compatibility?
5. How will users discover and use this feature?

Remember: **Better to implement something simple and useful than something complex and complete.** 