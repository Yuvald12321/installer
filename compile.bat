call ".venv\Scripts\pyinstaller.exe" --onefile --noconsole --icon "logo.ico" -n "Installer" main.py
rd /S /Q "build"