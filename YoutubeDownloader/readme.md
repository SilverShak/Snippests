## Prerequisites
python -m pip install --upgrade pytube
python -m pip install --upgrade pyinstaller

## compile
increment version in 'sys_info'
pyinstaller --onefile --noconsole youtube_downloader.py
