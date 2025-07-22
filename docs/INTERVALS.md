# upKep Interval Recommendations

This document explains the recommended intervals for different types of maintenance operations in upKep.

## Overview

upKep uses category-based intervals to balance system freshness, performance, and stability. Each category has default intervals that can be overridden by individual modules when needed.

## Category Defaults

### Package Managers (7 days default)
- **Purpose**: Update system packages and applications
- **Risk Level**: Medium (updates can occasionally break things)
- **Recommended Range**: 3-7 days
- **Rationale**: Balance security updates with system stability

### System Cleanup (3 days default)
- **Purpose**: Remove old files, clean caches, free disk space
- **Risk Level**: Low (cleanup operations are generally safe)
- **Recommended Range**: 1-3 days
- **Rationale**: Prevent disk space issues without being excessive

### Security (3 days default)
- **Purpose**: Security updates, vulnerability scans, firewall checks
- **Risk Level**: Low (security operations are critical but safe)
- **Recommended Range**: 1-3 days
- **Rationale**: Maintain security posture without overwhelming the system

### Monitoring (3 days default)
- **Purpose**: Check system health, performance, resource usage
- **Risk Level**: Very Low (monitoring is read-only)
- **Recommended Range**: 1-7 days
- **Rationale**: Provide visibility without performance impact

## Module-Specific Overrides

Some modules need different intervals than their category default. Use the `interval_override` configuration:

```yaml
modules:
  apt_update:
    enabled: true
    category: package_managers
    interval_days: 3  # Override category default of 7
    interval_override:
      enabled: true
      interval_days: 3
      reason: "Security updates should be applied more frequently"
```

## Recommended Overrides

### Package Managers
- **apt_update**: 3 days (security-focused)
- **snap_update**: 7 days (uses category default)
- **flatpak_update**: 7 days (uses category default)

### System Cleanup
- **apt_cleanup**: 2 days (prevent disk space issues)
- **temp_cleanup**: 1 day (daily cleanup for performance)
- **docker_cleanup**: 7 days (resource-intensive)

### Security
- **security_updates**: 1 day (critical security)
- **vulnerability_scan**: 3 days (uses category default)
- **ssl_cert_check**: 7 days (certificates don't change frequently)

### Monitoring
- **system_health**: 2 days (regular monitoring)
- **service_status**: 1 day (critical services)
- **performance_check**: 5 days (less frequent metrics)

## Configuration Examples

### Conservative Setup (Recommended for Most Users)
```yaml
defaults:
  categories:
    package_managers:
      default_interval: 7
    system_cleanup:
      default_interval: 3
    security:
      default_interval: 3
    monitoring:
      default_interval: 3
```

### Aggressive Setup (For Power Users)
```yaml
defaults:
  categories:
    package_managers:
      default_interval: 3
    system_cleanup:
      default_interval: 1
    security:
      default_interval: 1
    monitoring:
      default_interval: 1
```

### Minimal Setup (For Resource-Constrained Systems)
```yaml
defaults:
  categories:
    package_managers:
      default_interval: 14
    system_cleanup:
      default_interval: 7
    security:
      default_interval: 7
    monitoring:
      default_interval: 7
```

## Best Practices

1. **Start Conservative**: Begin with category defaults and adjust based on needs
2. **Document Overrides**: Always provide a reason when overriding intervals
3. **Monitor Performance**: Watch for any issues when changing intervals
4. **Test Changes**: Use `--dry-run` to test new configurations
5. **Keep It Simple**: Avoid complex interval logic - stick to simple day-based intervals

## Troubleshooting

### Too Frequent Operations
- Increase intervals if operations are running too often
- Check for conflicting module configurations
- Verify category defaults are appropriate

### Too Infrequent Operations
- Decrease intervals if system maintenance is lacking
- Consider module-specific overrides for critical operations
- Review security and cleanup needs

### Performance Issues
- Increase intervals for resource-intensive operations
- Use longer timeouts for complex modules
- Consider disabling non-critical modules

## Migration from Legacy Configuration

If you have existing interval configurations, they will be automatically mapped:

- `update_interval` → `categories.package_managers.default_interval`
- `cleanup_interval` → `categories.system_cleanup.default_interval`
- `security_interval` → `categories.security.default_interval`

The legacy settings are maintained for backward compatibility but are deprecated. 