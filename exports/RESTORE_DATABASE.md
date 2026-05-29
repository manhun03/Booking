# Restore DoAnHotelParkingDb on another machine

Copy `DoAnHotelParkingDb.bak` to the target machine, for example:

`C:\Temp\DoAnHotelParkingDb.bak`

Then run this command:

```powershell
sqlcmd -S localhost,1433 -U sa -P YOUR_PASSWORD -C -Q "RESTORE DATABASE [DoAnHotelParkingDb] FROM DISK = N'C:\Temp\DoAnHotelParkingDb.bak' WITH REPLACE, RECOVERY, STATS = 10"
```

If SQL Server reports that logical files need paths, check logical names:

```powershell
sqlcmd -S localhost,1433 -U sa -P YOUR_PASSWORD -C -Q "RESTORE FILELISTONLY FROM DISK = N'C:\Temp\DoAnHotelParkingDb.bak'"
```

Then restore with explicit file locations:

```powershell
sqlcmd -S localhost,1433 -U sa -P YOUR_PASSWORD -C -Q "RESTORE DATABASE [DoAnHotelParkingDb] FROM DISK = N'C:\Temp\DoAnHotelParkingDb.bak' WITH MOVE N'DoAnHotelParkingDb' TO N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\DoAnHotelParkingDb.mdf', MOVE N'DoAnHotelParkingDb_log' TO N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\DoAnHotelParkingDb_log.ldf', REPLACE, RECOVERY, STATS = 10"
```

Update the Java backend connection string if the target machine uses a different host, username, or password.
