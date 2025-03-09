# Dotfiles

This repository contains my personal dotfiles for configuring various tools and applications on Linux. Feel free to use them to set up your own environment.

## Setup Instructions

1. **Clone the Repository**

   Clone this repository to your home directory under a `dotfiles` folder:

   ```bash
   git clone https://github.com/jdu211171/dotfiles.git ~/dotfiles
   ```

2. **Backup Existing Configurations (Optional but Recommended)**

   To avoid losing your current configurations, create a backup directory and move any existing files or directories that might be overwritten:

   ```bash
   mkdir ~/dotfiles-backup
   ```

   Then, manually back up any files or directories from your home directory (e.g., `~/.gitconfig`, `~/.zshrc`) or `~/.config/` (e.g., `~/.config/kitty`, `~/.config/nvim`) that match the ones in this repository. For example:

   ```bash
   mv ~/.gitconfig ~/dotfiles-backup/
   mv ~/.zshrc ~/dotfiles-backup/
   mv ~/.config/kitty ~/dotfiles-backup/kitty
   # Repeat for other files and directories as needed
   ```

3. **Create Symbolic Links**

   Link the configuration files and directories from the repository to their appropriate locations:

   - **For files starting with a dot** (e.g., `.gitconfig`, `.zshrc`):
     These should be linked directly to your home directory (`~`).

     ```bash
     ln -s ~/dotfiles/.gitconfig ~/.gitconfig
     ln -s ~/dotfiles/.zshrc ~/.zshrc
     # Add similar commands for other dotfiles
     ```

   - **For directories not starting with a dot** (e.g., `kitty`, `nvim`):
     These are typically configuration directories that should be linked to `~/.config/`.

     ```bash
     ln -s ~/dotfiles/kitty ~/.config/kitty
     ln -s ~/dotfiles/nvim ~/.config/nvim
     # Add similar commands for other directories
     ```

   Note: Some configurations may reference additional files or directories within `~/dotfiles` (e.g., themes or scripts). These do not need separate linking as long as they remain in the repository and are correctly referenced.

4. **Reload Your Shell**

   To apply the changes, open a new terminal or reload your shell configuration:

   ```bash
   source ~/.zshrc
   ```

## Updating Configurations

To update your configurations with the latest changes from this repository:

1. **Navigate to the dotfiles directory**:

   ```bash
   cd ~/dotfiles
   ```

2. **Pull the latest changes**:

   ```bash
   git pull origin main
   ```

   Replace `main` with the appropriate branch name if necessary.

3. **Recreate symbolic links** (if needed):

   If new files or directories have been added, repeat the linking process for those new items as described in the setup instructions.

4. **Reload your shell** (if necessary):

   Some changes may require reloading your shell or restarting applications for the updates to take effect:

   ```bash
   source ~/.zshrc
   ```

**Note**: If you have made local changes to your configurations, commit those changes before updating to avoid losing them.

## Notes

- **Overwriting Configurations**: The symbolic links will overwrite any existing files or directories at the target locations. Ensure you’ve backed up anything you want to keep before linking.
- **Expanding Configurations**: As new files or directories are added to this repository, repeat step 3 of the setup instructions for each new item, linking dotfiles to `~` and configuration directories to `~/.config/` as appropriate.

Enjoy your new setup!
