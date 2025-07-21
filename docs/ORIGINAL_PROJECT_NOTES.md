**Project Name:** upKep

**Current State Description**

**Purpose:**
`upKep` is a Linux system maintenance script that automates routine package updates and cleanup tasks. It centralizes updates across APT, Snap, and Flatpak package managers, while tracking the last execution times to avoid unnecessary operations. It is designed to be run periodically or manually, ensuring that the system stays current without user intervention unless required. The current script is available in the project files as **`upkep.sh`**.

---

### **Key Functions**

1. **State Tracking:**

   * Maintains a hidden state file (`~/.upkep_state`) recording timestamps of the last update, cleanup, and script execution.
   * Uses these timestamps to determine whether to skip or perform updates and cleanup based on predefined intervals (7 days for updates, 30 days for cleanup).

2. **Update Management:**

   * Runs `apt update && apt upgrade -y` for Debian/Ubuntu-based systems.
   * Refreshes Snap packages (`snap refresh`).
   * Updates Flatpak packages (`flatpak update -y`).
   * Provides success or failure status for each package manager.

3. **System Cleanup:**

   * Executes `apt autoremove -y` and `apt clean` to remove unused packages and caches when the cleanup interval is reached.

4. **Output and Display:**

   * Prints a detailed, colorized summary of the operations performed, including skipped steps, successes, or failures.
   * Uses Unicode box drawing and ASCII art for structured, readable output.
   * Provides a `--status` flag to display the time since the last updates, cleanup, and script run without making changes.

5. **Manual Overrides:**

   * Accepts a `--force` flag to bypass interval checks and run all tasks unconditionally.

6. **Progress Feedback:**

   * Includes a spinner animation to show ongoing background tasks.
   * Concludes with a summary report showing the results of APT, Snap, Flatpak, and cleanup tasks.

---

### **Behavior and Workflow**

* When run, `upKep` checks the state file for timestamps.
* It compares these timestamps with the defined update and cleanup intervals.
* It runs updates or cleanup only if the defined thresholds are met (or if `--force` is used).
* After execution, it updates the state file with new timestamps.
* The script outputs a visual summary to indicate what was done, skipped, or failed.

---

### **Current Limitations and Scope**

* Targets only systems with APT, Snap, and Flatpak. No support for other package managers.
* Relies on `sudo` privileges for updates and cleanup.
* Does not handle system reboots or kernel updates beyond standard APT upgrades.
* No scheduling mechanism; it must be run manually or via cron/systemd timers.
* Error handling is limited to success/failure statuses without deep diagnostics.

---

**Project Definition: upKep**

`upKep` is a Linux maintenance utility designed to automate core system upKep tasks across multiple package managers. It reduces manual intervention by batching updates for APT, Snap, and Flatpak, while periodically cleaning unused packages and caches. The tool maintains an internal state file (`~/.upkep_state`) to track the last execution of updates and cleanup, applying defined intervals (7 days for updates, 30 days for cleanup) to determine when actions are required. Users can override these intervals with the `--force` option or view the current maintenance status with `--status`.

The script delivers structured, color-coded output for clarity, including real-time progress indicators and a summary of results. It is designed for Debian/Ubuntu-based systems and assumes `sudo` access for privileged operations. While it offers no built-in scheduling, it is well-suited for use with cron or systemd timers.

The current implementation of **`upKep`** is contained in the project file **`upkep.sh`**, which represents version 3.1 of the script. Future iterations could expand support to other package managers, introduce advanced logging, or integrate with system monitoring tools.
