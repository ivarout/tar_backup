# tar_backup
A simple Bash script for incremental tar backup automation on Linux.

## Useage

```
./tar_backup.sh [-r] [-f <incremental backup file>] <target directory>
```

Create an (incremental) backup of the specified directory using:
```
./tar_backup.sh <target directory>
```
The created backup files are stored in the current directory under the name `<target directory>.<yy_mm_dd_H_M_S>.tar.gz`

Recover data from created backup using:
```
./tar_backup.sh -r <target directory>
```

Or only recover up to a specified incremental backup using:
```
./tar_backup.sh -r -f <incremental backup>.tar.gz <target directory>
```
