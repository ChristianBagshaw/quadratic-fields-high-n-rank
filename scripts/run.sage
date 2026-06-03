import os
import sys

# --- Path setup
project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
src_path = os.path.join(project_root, 'src')
if src_path not in sys.path:
    sys.path.insert(0, src_path)

load(os.path.join(src_path, "algorithm.sage"))
load(os.path.join(src_path, "cli.sage"))

# --- Help
check_help()

# --- Parameters
P_VALUE = get(1, "p", int)
LAMBDA_PAIRS = get(2, "lambda pairs", parse_pairs)
LOWER_M1 = get(3, "lower m1", int)
UPPER_M1 = get(4, "upper m1", int)
OUTPUT_FILE = get(5, "discriminant output file", parse_txt, "discriminants.txt")
VERBOSE_OUTPUT = get(6, "verbose", parse_bool, True)
EXPLICIT_TESTING = get(7, "explicit testing", parse_bool, False)

# --- Output location
output_dir = os.path.join(project_root, 'data')
os.makedirs(output_dir, exist_ok=True)
output_file_path = os.path.join(output_dir, OUTPUT_FILE)

# --- Run Algorithm 3.2
p_rank_allsteps(
    p=P_VALUE,
    lambda_pairs=LAMBDA_PAIRS,
    lower_m1=LOWER_M1,
    upper_m1=UPPER_M1,
    output_file=output_file_path,
    explicit_testing_3=EXPLICIT_TESTING,
    verbose=VERBOSE_OUTPUT,
)
