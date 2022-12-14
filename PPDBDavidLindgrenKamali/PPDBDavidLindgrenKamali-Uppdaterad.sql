CREATE DATABASE PPDBDavidLindgrenKamali
GO

USE [PPDBDavidLindgrenKamali]
GO
/****** Object:  UserDefinedFunction [dbo].[VehicleCost]    Script Date: 2021-02-07 23:56:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[VehicleCost](@ParkedTime int, @VehicleType int)
Returns int As
begin
	set @ParkedTime = @ParkedTime - 5
	declare @ParkedHour int = @ParkedTime / 60 --hour
	declare @AddHour int = @ParkedTime % 60 --Minutes over hour
	declare @TotalCost int -- total cost

	if (@ParkedTime >= 5 AND @ParkedTime <= 140)
	begin
		if(@VehicleType = 1)
		Begin
			return 20
		end

		if(@VehicleType = 2)
		begin
			return 40
		end
	end

	else
	begin
		return 0
	end

	if (@AddHour > 0)
	begin
		set @ParkedHour = @ParkedHour + 1
	end

	if(@VehicleType = 1)
	begin
		set @TotalCost = @ParkedHour * 10
		return @TotalCost
	end

	else
	begin
		set @TotalCost = @ParkedHour * 20
		return @TotalCost
	end

	return @totalcost
end


GO
/****** Object:  Table [dbo].[ParkingHistory]    Script Date: 2021-02-07 23:56:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ParkingHistory](
	[HistoryID] [int] IDENTITY(1,1) NOT NULL,
	[RegNumber] [nvarchar](10) NULL,
	[VehicleStartTime] [datetime] NOT NULL,
	[VehicleEndTime] [datetime] NOT NULL,
	[ParkedTime] [int] NOT NULL,
	[Cost] [int] NOT NULL,
	[VehicleTypeID] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[HistoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Parkinglot]    Script Date: 2021-02-07 23:56:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Parkinglot](
	[ParkinglotID] [int] IDENTITY(1,1) NOT NULL,
	[Size] [int] NOT NULL,
	PRIMARY KEY(ParkinglotID)
);

GO
/****** Object:  Table [dbo].[Vehicle]    Script Date: 2021-02-07 23:56:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Vehicle](
	[VehicleID] [int] NOT NULL IDENTITY(1,1),
	[RegNumber] [nvarchar](10) NOT NULL,
	[VehicleTypeID] [int] NOT NULL,
	[ParkinglotID] [int] NULL FOREIGN KEY REFERENCES Parkinglot(ParkinglotID),
	[VehicleTime] [datetime] NOT NULL,
	PRIMARY KEY (VehicleID)
	);
GO
/****** Object:  Table [dbo].[VehicleTypes]    Script Date: 2021-02-07 23:56:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VehicleTypes](
	[VehicleTypeID] [int] NOT NULL,
	[VehicleType] [varchar](3) NOT NULL,
	PRIMARY KEY (VehicletypeID)
	);
GO
ALTER TABLE [dbo].[Parkinglot] ADD  DEFAULT ((0)) FOR [Size]
GO
ALTER TABLE [dbo].[Vehicle]  WITH CHECK ADD FOREIGN KEY([VehicleTypeID])
REFERENCES [dbo].[VehicleTypes] ([VehicleTypeID])
GO
ALTER TABLE [dbo].[ParkingHistory]  WITH CHECK ADD CHECK  ((len([RegNumber])>(2) AND len([RegNumber])<(11)))
GO
ALTER TABLE [dbo].[ParkingHistory]  WITH CHECK ADD CHECK  (([VehicleTypeID]=(2) OR [VehicleTypeID]=(1)))
GO
ALTER TABLE [dbo].[Parkinglot]  WITH CHECK ADD CHECK  (([ParkinglotID]<(201)))
GO
ALTER TABLE [dbo].[Parkinglot]  WITH CHECK ADD CHECK  (([Size]>=(0) AND [Size]<=(2)))
GO
ALTER TABLE [dbo].[Vehicle]  WITH CHECK ADD CHECK  (([VehicleTypeID]>(0) AND [VehicleTypeID]<(3)))
GO
ALTER TABLE [dbo].[VehicleTypes]  WITH CHECK ADD CHECK  (([VehicleTypeID]=(2) OR [VehicleTypeID]=(1)))
GO
ALTER TABLE [dbo].[VehicleTypes]  WITH CHECK ADD CHECK  (([VehicleType]='MC' OR [VehicleType]='Car'))
GO
/****** Object:  StoredProcedure [dbo].[Add_Vehicle]    Script Date: 2021-02-07 23:56:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[Add_Vehicle] @Regnumber nvarchar(10), @VehicleSize int, @VehicleTime datetime
AS
begin
	declare @regTrue int = 0
	if((select RegNumber from Vehicle Where RegNumber = @Regnumber) = @Regnumber)
	begin
		return 0
	end

	else
	begin
		set @regTrue = 1
		declare @Counter int = 1
		While @Counter < 100
		Begin --2
			declare @ParkinglotSize int = 0
			Set @ParkinglotSize = @VehicleSize + (select size from Parkinglot where ParkinglotID = @Counter)

			If(((select Size from Parkinglot WHERE ParkinglotID = @Counter) + @VehicleSize) <= 2)
			Begin--3
				Update Parkinglot Set Size = @ParkinglotSize Where ParkinglotID = @Counter
				Update Vehicle Set ParkinglotID = @Counter Where ParkinglotID = @Counter

				Insert into Vehicle(RegNumber, VehicleTypeID, VehicleTime, ParkinglotID)
				Values(@RegNumber, @VehicleSize, @VehicleTime, @Counter)

				return @Counter
			End--3
			set @Counter = @Counter + 1
		End
	end

if(@regTrue = 0)
	begin
		return 0
	end

else
	begin
		return -1
	end
end

GO
/****** Object:  StoredProcedure [dbo].[All_Vehicles]    Script Date: 2021-02-07 23:56:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [dbo].[All_Vehicles]
as
select p.ParkinglotID,  v.RegNumber, v.VehicleTime, vt.VehicleType, (Datediff(minute, v.VehicleTime,GetDate())/60) as Hours, (v.VehicleTypeID * 20) as [Price per hour], dbo.VehicleCost((DATEDIFF(minute, v.VehicleTime, GetDate())), v.VehicleTypeID) As [Current Cost]
from Vehicle v

left join Parkinglot p on (p.ParkinglotID = v.ParkinglotID)
join VehicleTypes vt on v.VehicleTypeID = vt.VehicleTypeID
order by ParkinglotID
GO
/****** Object:  StoredProcedure [dbo].[Delete_Vehicle]    Script Date: 2021-02-07 23:56:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Delete_Vehicle] @Regnumber nvarchar(10)
as
begin
	declare @EndTime datetime = GetDate() --hämtar databas datum
	declare @StartTime datetime = (select VehicleTime from Vehicle Where RegNumber = @Regnumber)
	declare @ParkedTime int = DATEDIFF(minute, @StartTime, @EndTime) 
	declare @VehicleTypeID int = (select VehicleTypeID from Vehicle Where RegNumber = @Regnumber) 
	declare @Parkinglot int

	If((select RegNumber from Vehicle Where RegNumber = @Regnumber) = @Regnumber)
	begin
		if((select ParkinglotID from Vehicle Where RegNumber = @Regnumber) IS NOT NULL)
		begin
			Insert ParkingHistory(RegNumber, VehicleStartTime, VehicleEndTime, ParkedTime, Cost, VehicleTypeID) Values (@Regnumber, @StartTime, @EndTime, @ParkedTime, dbo.VehicleCost(@ParkedTime, @VehicleTypeID), @VehicleTypeID)

			If((select ParkinglotID from Vehicle where RegNumber = @Regnumber) IS NOT NULL)
			begin
				Set @Parkinglot = (Select ParkinglotID from Vehicle Where Regnumber = @Regnumber) 

				Update Vehicle 
				Set ParkinglotID = NULL
				Where RegNumber = @Regnumber
			
				Delete
				from Vehicle
				Where RegNumber = @Regnumber 
				
				Update Parkinglot
				Set Size = Size - @VehicleTypeID
				Where ParkinglotID = @Parkinglot

				return @Parkinglot
				end
			end
		else
		begin
			return 0
		end
	end
end


GO
/****** Object:  StoredProcedure [dbo].[Move_Vehicle]    Script Date: 2021-02-07 23:56:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[Move_Vehicle] @Regnumber nvarchar(10), @InputParkinglot int
as
begin
	declare @VehicleSize int = (select VehicleTypeID from Vehicle Where RegNumber = @Regnumber)
	declare @CurrentParkinglot int

	if((select ParkinglotID from Vehicle Where RegNumber = @Regnumber) IS NOT NULL)
	begin
		if(((select Size from Parkinglot where ParkinglotID = @InputParkinglot) + (@VehicleSize)) <= 2)
		begin
			set @CurrentParkinglot = (Select ParkinglotID from Vehicle Where RegNumber = @Regnumber)
			Update Parkinglot Set Size = Size - @VehicleSize Where ParkinglotID = @CurrentParkinglot 
			Update Vehicle Set ParkinglotID = NULL Where Regnumber = @Regnumber 

			Update Parkinglot Set Size = Size + @VehicleSize Where ParkinglotID = @InputParkinglot
			Update Vehicle Set ParkinglotID = @InputParkinglot Where RegNumber = @Regnumber
			return @CurrentParkinglot
		end	
	end
end
begin
	return 0
end

GO
/****** Object:  StoredProcedure [dbo].[Parking_History]    Script Date: 2021-02-07 23:56:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [dbo].[Parking_History] @Regnumber nvarchar(10)
as
select ph.HistoryID, ph.RegNumber, vt.VehicleType, ph.VehicleStartTime, ph.VehicleEndTime, (ph.ParkedTime/60) as [Hours Parked], ph.Cost from ParkingHistory ph
join VehicleTypes vt on ph.VehicleTypeID = vt.VehicleTypeID
Where ph.RegNumber = @Regnumber
GO
/****** Object:  StoredProcedure [dbo].[Search_EmptyParkinglots]    Script Date: 2021-02-07 23:56:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [dbo].[Search_EmptyParkinglots]
as
select p.ParkinglotID, p.Size from Parkinglot p
GO
/****** Object:  StoredProcedure [dbo].[Search_Vehicle]    Script Date: 2021-02-07 23:56:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select v.RegNumber, vt.VehicleType, v.VehicleTime, p.ParkinglotID, (Datediff(minute, v.VehicleTime,GetDate())/60) as Hours, (v.VehicleTypeID * 20) as [Price per hour], dbo.VehicleCost((DATEDIFF(minute, v.VehicleTime, GetDate())), v.VehicleTypeID) As [Current Cost] from Vehicle v

--join Parkinglot p On v.RegNumber = p.RegNumber1 or v.RegNumber = p.RegNumber2
--join VehicleTypes vt on v.VehicleTypeID = vt.VehicleTypeID
--Where v.RegNumber = @Regnumber


CREATE Procedure [dbo].[Search_Vehicle] @Regnumber nvarchar(10)
as
begin
	if((select RegNumber from Vehicle Where RegNumber = @Regnumber) = @Regnumber)
	begin
		select p.ParkinglotID, v.RegNumber, vt.VehicleType, v.VehicleTime, (Datediff(minute, v.VehicleTime,GetDate())/60) as Hours, (v.VehicleTypeID * 20) as [Price per hour], dbo.VehicleCost((DATEDIFF(minute, v.VehicleTime, GetDate())), v.VehicleTypeID) As [Current Cost] from Vehicle v
		join Parkinglot p On v.ParkinglotID = p.ParkinglotID
		join VehicleTypes vt on v.VehicleTypeID = vt.VehicleTypeID
		Where v.RegNumber = @Regnumber
	end
end

GO
/****** Object:  StoredProcedure [dbo].[Top1_ParkingHistory]    Script Date: 2021-02-07 23:56:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [dbo].[Top1_ParkingHistory] @Regnumber nvarchar(10)
as
	select TOP 1 ph.HistoryID, ph.RegNumber, vt.VehicleType, ph.VehicleStartTime, ph.VehicleEndTime, (ph.ParkedTime/60) as [Hours Parked], ph.Cost from ParkingHistory ph
	join VehicleTypes vt on ph.VehicleTypeID = vt.VehicleTypeID
	Where ph.RegNumber = @Regnumber
	order by ph.HistoryID desc
GO

--Creates example data
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
GO