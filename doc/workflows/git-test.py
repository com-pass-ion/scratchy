"""
Workflow Test: Git + Diff (Magit + diff-hl)

INSTRUCTIONS:
1. Open this file in Emacs
2. Test diff-hl:
   - Make changes to this file
   - See colored indicators in left fringe
   - Green = added, Red = deleted, Blue = modified
   - C-x v n / C-x v p to navigate hunks
   - C-x v = to see diff for current hunk
3. Test magit:
   - M-x magit-status to open git status
   - s to stage files
   - u to unstage files
   - c c to create commit
   - P to push
   - F to pull
   - b b to switch branch
4. Test integration:
   - Changes show in fringe (diff-hl)
   - Magit shows status buffer
   - Commit works from magit
"""

# Test 1: Basic function (verify diff-hl shows in fringe)
def hello_git():
    """Test function for git workflow."""
    print("Hello from git test!")

# Test 2: Class (verify changes show correctly)
class GitTest:
    """Test class for git workflow."""

    def __init__(self, name):
        """Initialize with name."""
        self.name = name

    def get_name(self):
        """Get the name."""
        return self.name

    def set_name(self, name):
        """Set the name."""
        self.name = name

# Test 3: Modified function (make changes to see diff)
def calculate_average(numbers):
    """Calculate average of numbers."""
    if not numbers:
        return 0
    return sum(numbers) / len(numbers)

# Test 4: New function (add to see green indicator)
def calculate_median(numbers):
    """Calculate median of numbers."""
    if not numbers:
        return 0
    sorted_nums = sorted(numbers)
    n = len(sorted_nums)
    if n % 2 == 0:
        return (sorted_nums[n//2 - 1] + sorted_nums[n//2]) / 2
    else:
        return sorted_nums[n//2]

# Test 5: List operations
data = [10, 20, 30, 40, 50]

# Test 6: Print results
if __name__ == "__main__":
    hello_git()

    test = GitTest("Scratchy")
    print(f"Name: {test.get_name()}")

    print(f"Average: {calculate_average(data)}")
    print(f"Median: {calculate_median(data)}")

# VERIFICATION:
# - [ ] diff-hl shows indicators (left fringe)
# - [ ] Green indicator for additions
# - [ ] Red indicator for deletions
# - [ ] Blue indicator for modifications
# - [ ] C-x v n/p navigates hunks
# - [ ] C-x v = shows diff
# - [ ] M-x magit-status opens status
# - [ ] Magit commit works
# - [ ] Changes tracked correctly
