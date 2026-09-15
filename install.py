from pathlib import Path
import os
import shutil
import json
import subprocess


CATEGORIES = ["base", "desktop", "fonts", "development", "applications", "latex"]
DOTFILES = ["niri", "alacritty", "waybar", "rofi", "dunst"]
SERVICES = ["NetworkManager", "bluetooth", "sddm"]
BASE_DIR = Path(__file__).resolve().parent


def check_root():
    if os.geteuid() == 0:
        raise RuntimeError("Do not run this script as root.")


def load_packages_json():
    with open(BASE_DIR / "packages.json", "r", encoding="utf-8") as file:
        lines = [line for line in file if "//" not in line]
        return json.loads("".join(lines))


def run_command(command, cwd=None):
    subprocess.run(command, check=True, cwd=cwd)


def update_system():
    run_command(["sudo", "pacman", "-Syu", "--noconfirm"])


def install_yay():
    print("===> Installing AUR helper (yay)")

    yay_dir = Path("/tmp/yay")

    if shutil.which("yay"):
        print("yay is already installed")
        return

    run_command(["sudo", "pacman", "-S", "--needed", "git", "base-devel"])

    if not yay_dir.exists():
        run_command(["git", "clone", "https://aur.archlinux.org/yay.git", str(yay_dir)])

    run_command(["makepkg", "-si"], cwd=yay_dir)


def install_via_pacman(packages):
    if not packages:
        return

    run_command(["sudo", "pacman", "-S", "--needed", "--noconfirm", *packages])


def install_via_aur(packages):
    if not packages:
        return

    run_command(["yay", "-S", "--needed", "--noconfirm", *packages])


def install_category(packages_json, category: str):
    print(f"===> Installing packages from {category} category")

    packages = packages_json[category]["packages"]
    pacman_list = []  # pkg for pkg in packages_json[category] if pkg["source"] == "pacman"]
    aur_list = []  # pkg for pkg in packages_json[category] if pkg["source"] == "aur"]

    for pkg in packages:
        if pkg["source"] == "pacman":
            pacman_list.append(pkg["name"])
        elif pkg["source"] == "aur":
            aur_list.append(pkg["name"])
        else:
            raise ValueError(
                f"Error: for package:{pkg} unknown source: {pkg['source']}. Pls check it in file packages.json"
            )

    install_via_pacman(pacman_list)
    install_via_aur(aur_list)


def install_pkgs():
    print("===> Installing packages")

    packages_json = load_packages_json()

    for category in CATEGORIES:
        if category not in packages_json:
            raise ValueError(
                f"unknown category {category}. I cant find it in packages.json"
            )

        install_category(packages_json, category)


def copy_files(source_dir, destination_dir):  # TODO: is dir exist
    print(f"===> Copying files from {source_dir} to {destination_dir}")

    source_dir = Path(source_dir).expanduser()
    destination_dir = Path(destination_dir).expanduser()

    if not source_dir.exists():
        print(f"Warning: {source_dir} does not exist, skipping")
        return

    destination_dir.mkdir(parents=True, exist_ok=True)

    for file in source_dir.iterdir():
        if file.is_file():
            shutil.copy2(file, destination_dir / file.name)


def copy_dir(source_dir, destination_dir):  # TODO: is dir exist
    print(f"===> Copying files from {source_dir} to {destination_dir}")

    source_dir = Path(source_dir).expanduser()
    destination_dir = Path(destination_dir).expanduser()

    if not source_dir.exists():
        print(f"Warning: {source_dir} does not exist, skipping")
        return

    shutil.copytree(source_dir, destination_dir, dirs_exist_ok=True)


def copy_dotfiles():
    print("===> Copying dotfiles to .config/")

    for dir_name in DOTFILES:
        source_dir = BASE_DIR / dir_name
        destination_dir = Path(f"~/.config/{dir_name}").expanduser()
        copy_dir(source_dir, destination_dir)


def make_executable(directory):
    print(f"===> Making scripts from {directory} executable")

    directory = Path(directory).expanduser()

    for file in directory.iterdir():
        if file.is_file():
            file.chmod(file.stat().st_mode | 0o111)


def copy_scripts(source_dir=BASE_DIR / "scripts-niri"):
    print("===> Copying scripts")

    destination_dir = Path("~/.config/scripts-niri").expanduser()
    copy_files(source_dir, destination_dir)

    make_executable(destination_dir)


def copy_wallpapers(source_dir=BASE_DIR / "Wallpapers"):
    print("===> Copying wallpapers to ~/Wallpapers")

    destination_dir = Path("~/Wallpapers").expanduser()
    copy_files(source_dir, destination_dir)


def enable_services():
    print("===> Enabling NetworkManager, bluetooth, sddm services")

    for service in SERVICES:
        run_command(["sudo", "systemctl", "enable", "--now", service])


def install_oh_my_zsh():
    print("===> Installing Oh My Zsh")
    print("Run this command to install zsh:")
    print(
        "curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh"
    )

    # oh_my_zsh_dir = Path.home() / ".oh-my-zsh"
    #
    # if (oh_my_zsh_dir / "oh-my-zsh.sh").is_file():
    #     print("Oh My Zsh is already installed")
    #     return
    #
    # subprocess.run(
    #     "curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh",
    #     shell=True,
    #     check=True,
    # )
    # # sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    #
    # copy_dir(BASE_DIR / "zsh" / ".zsh", oh_my_zsh_dir)
    #
    # zshrc_file = BASE_DIR / "zsh" / ".zshrc"
    # if zshrc_file.is_file():
    #     shutil.copy2(zshrc_file, Path.home() / zshrc_file.name)


# pkief.material-icon-theme
# bbenoist.nix
# ms-python.python
# ms-python.mypy-type-checker
# ms-python.debugpy
# ms-python.vscode-python-envs
# formulahendry.code-runner
# llvm-vs-code-extensions.vscode-clangd
def install_vscodium_extensions(extensions=None):
    # TODO: add to packages.json
    if extensions is None:
        return

    print("===> Installing VSCodium extensions")

    if not shutil.which("codium"):
        raise RuntimeError("Sry, VSCodium is not installed")

    for extension in extensions:
        run_command(["codium", "--install-extension", extension])


if __name__ == "__main__":
    check_root()

    # update_system()
    install_yay()
    install_pkgs()

    enable_services()

    copy_dotfiles()
    copy_scripts()
    copy_wallpapers()

    install_oh_my_zsh()

    # install_vscodium_extensions()
