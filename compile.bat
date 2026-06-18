call ".venv\Scripts\pyinstaller.exe" --specpath "build" --onefile --noconsole --icon "logo.ico" -n "Installer" main.py
rd /S /Q "build"