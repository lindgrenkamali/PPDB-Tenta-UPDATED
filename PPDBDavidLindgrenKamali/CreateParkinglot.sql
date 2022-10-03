

declare @count int
set @count = (Select COUNT(*) from dbo.Parkinglot)
while @count < 100
begin
insert into dbo.Parkinglot (Size) 
values(0)
SET @count = @count + 1
end

insert into dbo.VehicleTypes (VehicleTypeID, VehicleType)
values(2, 'Car')

insert into dbo.VehicleTypes (VehicleTypeID, VehicleType)
values(1, 'MC')