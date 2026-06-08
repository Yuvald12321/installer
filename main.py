import customtkinter as ctk
from tkinter import filedialog, messagebox
from pathlib import Path
import requests

class Installer(ctk.CTk):
    def __init__(self):
        super().__init__()

        self.token = "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"
        self.headers = {"Authorization": f"token {self.token}"}
        self.username = "Yuvald12321"
        self.download_folder = Path.home() / "Downloads"
        self.ask_download_folder()

        self.title("Installer")
        self.geometry("300x200")
        self.grid_columnconfigure(0, weight=1)
        self.grid_rowconfigure(0, weight=1)

        self.programs = self.get_programs()

        self.program_selection_frame = ctk.CTkFrame(self)
        self.program_selection_frame.grid(row=0, column=0, padx=20, pady=20, sticky="nsew")
        self.program_selection_frame.grid_columnconfigure(0, weight=1)

        self.program_selection_label = ctk.CTkLabel(self.program_selection_frame, text="Select a program to install:")
        self.program_selection_label.grid(row=0, column=0, padx=10, pady=10)

        self.program_option_menu = ctk.CTkOptionMenu(self.program_selection_frame, values=list(self.programs.keys()))
        self.program_option_menu.grid(row=1, column=0, padx=10, pady=10, sticky="ew")
        self.program_option_menu.set("Select Program")

        self.install_button = ctk.CTkButton(self.program_selection_frame, text="Install", command=self.install_selected_program)
        self.install_button.grid(row=2, column=0, padx=10, pady=10)

    def install_selected_program(self):
        selected_program = self.program_option_menu.get()
        if selected_program != "Select Program" and selected_program in self.programs:
            download_url = self.programs[selected_program]
            try:
                self.download(selected_program, download_url)
                messagebox.showinfo("Success", f"Successfully downloaded {selected_program} to {self.download_folder}")
            except Exception as e:
                messagebox.showerror("Error", f"Error downloading {selected_program}: {type(e).__name__}: {str(e)}")
        else:
            messagebox.showwarning("Warning", "Please select a valid program.")

    def ask_download_folder(self):
        if not self.download_folder.exists():
            temp_download_folder = filedialog.askdirectory(title="Select the downloads folder")
            if temp_download_folder:
                self.download_folder = Path(temp_download_folder)
            else:
                self.ask_download_folder()

    def get_programs(self):
        programs_dict = {}
        try:
            repos_url = f"https://api.github.com/users/{self.username}/repos"
            repos_res = requests.get(repos_url, headers=self.headers)
            repos_res.raise_for_status()
            repos = [repo["name"] for repo in repos_res.json()]
            for repo in repos:
                dist_url = f"https://api.github.com/repos/{self.username}/{repo}/contents/dist"
                dist_res = requests.get(dist_url, headers=self.headers)
                if dist_res.status_code == 200:
                    for file_info in dist_res.json():
                        file_name = file_info["name"]
                        if file_name.lower().endswith(".exe"):
                            programs_dict[file_name] = file_info["download_url"]
        except Exception as e:
            messagebox.showerror("Error", f"{type(e).__name__}: {str(e)}")
        return programs_dict

    def download(self, download_name, download_url):
        download_path = self.download_folder / download_name
        download_res = requests.get(download_url, headers=self.headers)
        download_res.raise_for_status()
        data = download_res.content
        download_path.write_bytes(data)

if __name__ == "__main__":
    installer = Installer()
    installer.mainloop()