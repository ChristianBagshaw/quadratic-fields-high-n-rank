import sys

def get(i, name, cast=str, default=None):
    if i >= len(sys.argv):
        if default is not None:
            return default
        print(f"Missing required argument: {name}")
        print_usage()
        sys.exit()

    try:
        return cast(sys.argv[i])
    except (ValueError, TypeError):
        print(f"Invalid {name}: '{sys.argv[i]}'")
        print_usage()
        sys.exit()

def parse_pairs(s):
    """Parse '1,1;2,3' -> [(1,1), (2,3)]"""
    return [(int(x.split(',')[0]), int(x.split(',')[1])) for x in s.split(';')]

def parse_bool(s):
    """Parse various boolean representations."""
    return str(s).lower() in ("true", "1", "yes", "y")

def parse_txt(s):
    """Return the string if it ends with '.txt' (case-insensitive), else exit with error."""
    if not (isinstance(s, str) and s.strip().lower().endswith(".txt")):
        print(f"Expected a .txt filename, but got: '{s}'")
        print_usage()
        sys.exit(1)
    return s.strip()


def print_usage():
    """Print usage information."""
    print("\nThis script is intended to be run using SageMath from the command line.")
    print("To run it, use the following syntax:\n")

    print("Usage:")
    print("  sage scripts/run.sage <p> <lambda_pairs> <lower_m1> <upper_m1> [output] [verbose] [explicit]\n")

    print("Arguments:")
    print("  p              Prime number (integer)")
    print("  lambda_pairs   Pairs of lambda values, separated by semicolons (e.g., '1,1;2,3')")
    print("  lower_m1       Lower bound for m1 (integer)")
    print("  upper_m1       Upper bound for m1 (integer)")
    print("  output         Optional: txt file to dump discriminants (str, default: discriminants.txt)\n")
    print("  verbose        Optional: Print progress to screen (true/false, default: true)")
    print("  explicit       Optional: Perform explicit ideal testing for p=3 (true/false, default: false)\n")

    print("Examples:")
    print("  sage scripts/run.sage 3 '1,1;2,3' 2 150")
    print("  sage scripts/run.sage 5 '1,1' 10 100 testrun.txt true false\n")


def check_help():
    """Check for help flag and print usage if found."""
    if len(sys.argv) > 1 and sys.argv[1] in ['-h', '--help', 'help']:
        print_usage()
        sys.exit(0)
