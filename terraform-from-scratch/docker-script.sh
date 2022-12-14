sed "s/project='.*'/project='PROJECTNAME'/" ./backend-api/main.py
docker build -t crc-backend ./backend-api
docker tag crc-backend gcr.io/PROJECTNAME/crc-backend
docker push gcr.io/PROJECTNAME/crc-backend

