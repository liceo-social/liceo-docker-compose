#!/usr/bin/env bash

# 1 - VARIABLES ---------------------

LOG_PREFIX="masi:"
BACKUP_FS_PATH="/tmp/backup/fs"
BACKUP_DB_PATH="/tmp/backup/db"

# 2 - FUNCIONES ----------------------

# muestra como usar el comando masi.sh
function usage {
    echo "$LOG_PREFIX masi.sh (startup|shutdown|status|logs|backup|backup-up|backup-fs)"
}

# arranca los contenedores de docker
function app-run {
    echo "$LOG_PREFIX run-app"
    docker-compose up -d
}

# para los contenedores de docker
function app-stop {
    echo "$LOG_PREFIX stop-app"
    docker-compose stop
}

# muestra el estado de los contenedores de docker
function app-status {
    echo "$LOG_PREFIX showing status..."
    docker-compose ps
}

function app-logs {
    echo "$LOG_PREFIX mostrando logs del servicio..."
    docker-compose logs -f manager
}

# ejecuta el backup de base de datos y de ficheros
function backup {
    backup-db
    backup-fs
}

# ejecuta el backup de la base de datos
function backup-db {
    PREFIX="$LOG_PREFIX [backup-db]"        

    BACKUP_FILENAME="masi-db-$(date +%Y%m%d%H%M).sql"
    BACKUP_FILEPATH="$BACKUP_DB_PATH/$BACKUP_FILENAME"

    echo "$PREFIX creando fichero de backup $BACKUP_FILEPATH"
    docker-compose exec db sh -c "pg_dump -f $BACKUP_FILEPATH -U masiaventura masiaventura"

    echo "$PREFIX backup de la base dedatos terminado"
}

# ejecuta el backup de los ficheros
function backup-fs {
    PREFIX="$LOG_PREFIX [backup-fs]"

    BACKUP_FILENAME="masi-fs-$(date +%Y%m%d%H%M).tar.gz"
    BACKUP_FILEPATH="$BACKUP_FS_PATH/$BACKUP_FILENAME"
    SCRIPT='[ "$(ls -A /tmp/kk)" ] && tar -czf /tmp/backup/files/'$BACKUP_FILENAME' /tmp/kk/* || echo'

    echo "$PREFIX creando fichero de backup $BACKUP_FILEPATH"
    docker-compose exec manager bash -c "$SCRIPT"

    echo "$PREFIX backup de los ficheros terminado"
}

# 3 - ENTRY POINT ------------------
case $1 in
    startup)
        app-run
        ;;
    shutdown)
        app-stop
        ;;
    status)
        app-status
        ;;        
    logs)
        app-logs
        ;;
    backup)
        backup
        ;;
    backup-db)
        backup-db
        ;;
    backup-fs)
        backup-fs
        ;;
    *)
        usage
        ;;
esac