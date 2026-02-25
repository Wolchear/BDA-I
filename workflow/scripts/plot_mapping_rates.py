import argparse
import re
from pathlib import Path

import matplotlib.pyplot as plt

RATE_RE = re.compile(r"^\s*([0-9]+(?:\.[0-9]+)?)%\s+overall alignment rate\s*$", re.IGNORECASE)

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Parse HISAT2 logs and plot mapping rates.")
    parser.add_argument(
        "--dir", "-d",
        type=str,
        required=True,
        help="Input directory with HISAT2 log files"
    )
    parser.add_argument(
        "--output", "-o",
        type=str,
        required=True,
        help="Output file name"
    )
    parser.add_argument(
        "--glob", "-g",
        type=str,
        default="*.log",
        help="Glob pattern to select log files inside --dir (default: *.log)"
    )
    return parser.parse_args()

def extract_rate_from_file(path: Path) -> float:
    try:
        with path.open("r", encoding="utf-8", errors="replace") as f:
            for line in f:
                m = RATE_RE.match(line.strip())
                if m:
                    return float(m.group(1))
        raise ValueError(f"Could not find 'overall alignment rate' in: {path}")
    except Exception as e:
        raise Exception(f"Something goes wrong: {e}")

def save_plot(samples: list[str], mapping_rates: list[float], plot_path: Path) -> None:
    plt.figure()

    bars = plt.bar(samples, mapping_rates)

    plt.xlabel("Sample")
    plt.ylabel("Mapping rate (%)")
    plt.title("Mapping Rate per Sample")
    plt.ylim(0, 100)
    
    plt.xticks(rotation=45, ha="right")

    for bar, rate in zip(bars, mapping_rates):
        height = bar.get_height()
        plt.text(
            bar.get_x() + bar.get_width() / 2,
            height / 2 ,
            f"{rate:.2f}%",
            ha="center",
            va="bottom",
            fontsize=9
        )

    plt.tight_layout()
    plt.savefig(plot_path, dpi=300)


def main() -> None:
    args = parse_args()
    in_dir = Path(args.dir)

    files = sorted(in_dir.glob(args.glob))
    if not files:
        raise SystemExit(f"No files matched pattern '{args.glob}' in {in_dir}")

    samples: list[str] = []
    mapping_rates: list[float] = []
    errors: list[tuple[str, str]] = []

    for file in files:
        try:
            mapping_rates.append(extract_rate_from_file(file))
            samples.append(file.stem)
        except Exception as e:
            errors.append((str(file), str(e)))

    if not mapping_rates:
        msg = "No mapping rates extracted.\n"
        if errors:
            msg += "\n".join([f"- {f}: {err}" for f, err in errors])
        raise SystemExit(msg)

    save_plot(samples, mapping_rates, args.output)

    if errors:
        print("WARNING: some files could not be parsed:")
        for f, err in errors:
            print(f"  - {f}: {err}")

if __name__ == "__main__":
    main()