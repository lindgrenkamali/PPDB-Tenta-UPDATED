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
if (@ParkedTime <= 0)
begin
return 0
end

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

if (@AddHour > 0)
begin
set @ParkedHour = @ParkedHour + 1
end
if(@VehicleType = 1)
begin
set @TotalCost = @ParkedHour * 10
return @TotalCost
end
if(@VehicleType = 2)
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
	[RegNumber1] [nvarchar](10) NULL,
	[RegNumber2] [nvarchar](10) NULL,
	[Size] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ParkinglotID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Vehicle]    Script Date: 2021-02-07 23:56:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Vehicle](
	[RegNumber] [nvarchar](10) NOT NULL,
	[VehicleTypeID] [int] NOT NULL,
	[VehicleTime] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[RegNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VehicleTypes]    Script Date: 2021-02-07 23:56:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VehicleTypes](
	[VehicleTypeID] [int] NOT NULL,
	[VehicleType] [varchar](3) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[VehicleTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Parkinglot] ADD  DEFAULT ((0)) FOR [Size]
GO
ALTER TABLE [dbo].[Parkinglot]  WITH CHECK ADD FOREIGN KEY([RegNumber1])
REFERENCES [dbo].[Vehicle] ([RegNumber])
GO
ALTER TABLE [dbo].[Parkinglot]  WITH CHECK ADD FOREIGN KEY([RegNumber2])
REFERENCES [dbo].[Vehicle] ([RegNumber])
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
ALTER TABLE [dbo].[Parkinglot]  WITH CHECK ADD CHECK  ((len([RegNumber1])>(2) AND len([RegNumber1])<(11)))
GO
ALTER TABLE [dbo].[Parkinglot]  WITH CHECK ADD CHECK  ((len([RegNumber2])>(2) AND len([RegNumber2])<(11)))
GO
ALTER TABLE [dbo].[Parkinglot]  WITH CHECK ADD CHECK  (([Size]>=(0) AND [Size]<=(2)))
GO
ALTER TABLE [dbo].[Vehicle]  WITH CHECK ADD CHECK  ((len([RegNumber])>(2) AND len([RegNumber])<(11)))
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
begin --1
declare @regTrue int = 0
if((select RegNumber from Vehicle Where RegNumber = @Regnumber) = @Regnumber)
	begin
		return 0
			end

else
	begin
	set @regTrue = 1
		declare @Counter int = 1
				Insert into Vehicle(RegNumber, VehicleTypeID, VehicleTime) Values(@RegNumber, @VehicleSize, @VehicleTime)
					While @Counter < 100
						Begin --2
							declare @ParkinglotSize int = 0
							Set @ParkinglotSize = @VehicleSize + (select size from Parkinglot where ParkinglotID = @Counter)
If(((select RegNumber1 from Parkinglot Where ParkinglotID = @Counter)IS NULL) AND (((select Size from Parkinglot WHERE ParkinglotID = @Counter) + @VehicleSize) <= 2))
Begin--3
Update Parkinglot Set RegNumber1 = @RegNumber, Size = @ParkinglotSize Where ParkinglotID = @Counter
return @Counter
End--3
If(((select RegNumber2 from Parkinglot Where ParkinglotID = @Counter)IS NULL) AND(((select Size from Parkinglot WHERE ParkinglotID = @Counter) + @VehicleSize) <= 2))
Begin--4
Update Parkinglot Set RegNumber2 = @RegNumber, Size = @ParkinglotSize Where ParkinglotID = @Counter
return @Counter
end--5
Else
Begin
set @Counter = @Counter + 1
End

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
select p.ParkinglotID,  v.RegNumber, v.VehicleTime, vt.VehicleType, (Datediff(minute, v.VehicleTime,GetDate())/60) as Hours, (v.VehicleTypeID * 20) as [Price per hour], dbo.VehicleCost((DATEDIFF(minute, v.VehicleTime, GetDate())), v.VehicleTypeID) As [Current Cost] from Vehicle v

left join Parkinglot p on (p.RegNumber1 = v.RegNumber) or  (p.RegNumber2 = v.RegNumber)
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
declare @Counter int = 1 -- sätter counter till 1
declare @EndTime datetime = GetDate() --hämtar databas datum
declare @StartTime datetime = (select VehicleTime from Vehicle Where RegNumber = @Regnumber) --hämtar datum för fordon
declare @ParkedTime int = DATEDIFF(minute, @StartTime, @EndTime) --räknar ut antal minuter stådda
declare @VehicleTypeID int = (select VehicleTypeID from Vehicle Where RegNumber = @Regnumber) --kollar fordonstyp

If((select RegNumber from Vehicle Where RegNumber = @Regnumber) = @Regnumber)--om fordonet existerar kör detta
begin
While (@Counter < 100) --körs medan värdet är under 100
begin
if( ((select RegNumber1 from Parkinglot Where ParkinglotID = @Counter) = @Regnumber) or (select RegNumber2 from Parkinglot Where ParkinglotID = @Counter) = @Regnumber) --Om det angivna parkinglot id har regnummer, kör
begin
Insert ParkingHistory(RegNumber, VehicleStartTime, VehicleEndTime, ParkedTime, Cost, VehicleTypeID) Values (@Regnumber, @StartTime, @EndTime, @ParkedTime, dbo.VehicleCost(@ParkedTime, @VehicleTypeID), @VehicleTypeID)

If((select RegNumber1 from Parkinglot where ParkinglotID = @Counter) = @Regnumber)
begin
	Update Parkinglot Set RegNumber1 = NULL, Size = Size - @VehicleTypeID Where ParkinglotID = @Counter
			Delete from Vehicle Where RegNumber = @Regnumber --tar bort fordon
				return @counter
							end

If((select RegNumber2 from Parkinglot where ParkinglotID = @Counter) = @Regnumber)
begin
	Update Parkinglot Set RegNumber2 = NULL, Size = Size - @VehicleTypeID Where ParkinglotID = @Counter
			Delete from Vehicle Where RegNumber = @Regnumber --tar bort fordon
				return @counter
							end
End
set @Counter = @Counter + 1
End
end
return 0
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
declare @Counter int = 1


if((select RegNumber from Vehicle Where RegNumber = @Regnumber) = @Regnumber)
begin
if( ((select Size from Parkinglot where ParkinglotID = @InputParkinglot) + (@VehicleSize)) <= 2)--Kollar om fordonet får plats på den angivna platsen
begin
while (@Counter < 100)
begin

if((Select RegNumber1 from Parkinglot Where ParkinglotID = @Counter) = @Regnumber) --Kollar om platsen innehåller fordonet
begin
Update Parkinglot Set RegNumber1 = null, Size = Size - @VehicleSize Where ParkinglotID = @Counter --Tar bort Regnr1 från platsen


if((select RegNumber1 from Parkinglot Where ParkinglotID = @InputParkinglot) IS NULL) --Kollar om regnr1 är tom på den nya platsen
begin
Update Parkinglot Set RegNumber1 = @Regnumber, Size = Size + @VehicleSize Where ParkinglotID = @InputParkinglot -- sätter in det nya fordonet
return @Counter
end
else
begin
Update Parkinglot Set RegNumber2 = @Regnumber, Size = Size + @VehicleSize Where ParkinglotID = @InputParkinglot -- sätter in det nya fordonet
return @Counter
end
end

if((Select RegNumber2 from Parkinglot Where ParkinglotID = @Counter) = @Regnumber) --Kollar om platsen innehåller fordonet
begin
Update Parkinglot Set RegNumber2 = null, Size = Size - @VehicleSize Where ParkinglotID = @Counter --Tar bort Regnr2 från platsen


if((select RegNumber1 from Parkinglot Where ParkinglotID = @InputParkinglot) IS NULL) --Kollar om regnr1 är tom på den nya platsen
begin
Update Parkinglot Set RegNumber1 = @Regnumber, Size = Size + @VehicleSize Where ParkinglotID = @InputParkinglot -- sätter in det nya fordonet
return @Counter
end
else
begin
Update Parkinglot Set RegNumber2 = @Regnumber, Size = Size + @VehicleSize Where ParkinglotID = @InputParkinglot -- sätter in det nya fordonet
return @Counter
end
end
end
set @Counter = @Counter + 1
end
end
else
begin
return 0
end

return -1
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

if((select RegNumber from Vehicle Where RegNumber = @Regnumber) = @Regnumber)
begin
select p.ParkinglotID, v.RegNumber, vt.VehicleType, v.VehicleTime, (Datediff(minute, v.VehicleTime,GetDate())/60) as Hours, (v.VehicleTypeID * 20) as [Price per hour], dbo.VehicleCost((DATEDIFF(minute, v.VehicleTime, GetDate())), v.VehicleTypeID) As [Current Cost] from Vehicle v

join Parkinglot p On v.RegNumber = p.RegNumber1 or v.RegNumber = p.RegNumber2
join VehicleTypes vt on v.VehicleTypeID = vt.VehicleTypeID
Where v.RegNumber = @Regnumber
end
GO
/****** Object:  StoredProcedure [dbo].[Top1_ParkingHistory]    Script Date: 2021-02-07 23:56:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Procedure [dbo].[Top1_ParkingHistory] @Regnumber nvarchar(10)
as
return select TOP 1 ph.HistoryID, ph.RegNumber, vt.VehicleType, ph.VehicleStartTime, ph.VehicleEndTime, (ph.ParkedTime/60) as [Hours Parked], ph.Cost from ParkingHistory ph
join VehicleTypes vt on ph.VehicleTypeID = vt.VehicleTypeID
Where ph.RegNumber = @Regnumber
order by ph.HistoryID desc
GO
