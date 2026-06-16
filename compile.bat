pyinstaller --onefile --noconsole --icon "logo.ico" -n "Installer" main.py
rd /S /Q "build"
del /Q "Installer.spec"
