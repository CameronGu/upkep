# Quick Task Execution Prompt

**Before starting any upkep task:**

## 1. Evaluate Task Appropriateness
- Does this solve a real user problem in Linux system maintenance?
- Is this the **simplest** solution that works?
- Does this align with upkep's principles: **simplicity, maintainability, reliability, user-focused**?

**If unclear → reconsider the approach**

## 2. Implementation Standards
- **Write tests first** or immediately after coding
- Add test files to `tests/test_cases/` and update `tests/test_runner.sh`
- Follow existing code patterns and error handling
- Ensure backward compatibility

## 3. Mandatory Completion Steps
```bash
# Always run before marking task complete:
./tests/test_runner.sh
```

**All tests must pass (100% success rate) before task is considered done.**

## Success Criteria
✅ Solves user problem simply  
✅ Has comprehensive test coverage  
✅ Passes full test suite  
✅ Maintains code quality  
✅ Integrates cleanly  

**Remember: Simple and useful > Complex and complete** 