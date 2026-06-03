from tqdm.auto import tqdm

_BAR_FORMAT = "{desc}: |{bar}| {n}/{total} [{elapsed}s]"


def progress_bar(iterable, desc, verbose=True, leave=True):
    return tqdm(
        iterable,
        desc=desc,
        disable=not verbose,
        leave=leave,
        ascii=" █",
        bar_format=_BAR_FORMAT,
    )


class Reporter:
    """Console reporting for Algorithm 3.2
    """

    def __init__(self, verbose=True):
        self.verbose = verbose

    def _say(self, message=""):
        if self.verbose:
            print(message)

    def start(self, p, lambda_pairs, lower_m1, upper_m1):
        self._say("Algorithm 3.2")
        self._say(f"  prime p      = {p}")
        self._say(f"  lambda pairs = {lambda_pairs}")
        self._say(f"  m1 range     = [{lower_m1}, {upper_m1}]")
        self._say()

    def search_step(self):
        self._say("Step 1: searching for solutions and generating ideals")

    def lambda_pair(self, lambda1, lambda2):
        self._say(f"  lambda pair ({lambda1}, {lambda2})")

    def testing_step(self, use_p3_optimization):
        self._say()
        self._say("Step 2: testing collected ideals")
        if use_p3_optimization:
            self._say("  p=3 optimization: checking for multiple unique generators")
        else:
            self._say("  full independence testing via rankcheck")

    def result(self, p, count):
        self._say()
        self._say(f"Found {count} discriminants with {p}-rank > 1")

    def saving(self, count, output_file):
        self._say(f"Saving {count} discriminants to {output_file}")

    def saved(self):
        self._say("Save complete")

    def save_error(self, error):
        self._say(f"Error saving file: {error}")
