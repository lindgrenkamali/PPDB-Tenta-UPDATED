using System;
using System.Collections.Generic;
using System.Linq;
using PPDBDavidLindgrenKamaliBackEnd;
using PPDBDavidLindgrenKamaliBackEnd.VehicleProperties;

namespace PPDBDavidLindgrenKamaliFrontEnd
{
    class ADOMetoder
    {

        internal string AddVehicle(string regNumber)
        {

            return SQLMetoder.InsertVehicle(regNumber, CheckInTime(), CreateVehicleType());

        }

        internal string[] ParkedVehicles()
        {
            return SQLMetoder.AllVehicles();
        }

        internal string MoveVehicle()
        {

            return SQLMetoder.MoveVehicle(RegNumber(), ParkinglotPosition());
        }

        internal string SearchVehicle()
        {
            return SQLMetoder.SearchVehicle(RegNumber());
        }

        internal int ParkinglotPosition()
        {
            try
            {
                bool loop = true;
                int i;
                do
                {
                    Console.WriteLine("\nWhat position should the car move to? Only 1-100 are allowed");
                    i = int.Parse(Console.ReadLine());

                    if (i <= 100 || i >= 1)
                    {
                        loop = false;
                        return i;

                    }

                    else
                    {
                        Console.WriteLine("Invalid input. Try again.");
                    }

                } while (loop == true);

                return i;

            }
            catch (FormatException)
            {
                Console.WriteLine("\nYou have made inputs that aren't allowed. Please try again");

                return ParkinglotPosition();
            }
            catch (OverflowException)
            {
                Console.WriteLine("\nYou have assigned a value too low or too high. Please try again");
                return ParkinglotPosition();
            }

        }

        internal string[] NotFullParkinglot()
        {
            return SQLMetoder.EmptyParkingLots();
        }

        internal string DeleteVehicle(string regNr)
        {

            return SQLMetoder.DeleteVehicle(regNr);

        }

        internal List<string> ParkingHistory()
        {
            return SQLMetoder.ParkingHistorySearch(RegNumber());
        }

        internal string RegNumber()
        {

            string regNumber;

            bool trueDigit;
            bool loopReg = true;
            do
            {
                Console.WriteLine("Input your vehicles REGNUMBER. Only the amount of 3-10 digits and letters are allowed.");
                regNumber = Console.ReadLine();

                trueDigit = regNumber.All(x => Char.IsLetterOrDigit(x));
                regNumber = regNumber.ToUpper();

                if (trueDigit == false)
                {
                    Console.WriteLine("You can only use digits and numbers");
                }

                else if (regNumber.Length > 10 || regNumber.Length < 3)
                {
                    Console.WriteLine("The length of your REGNUMBER is not allowed. Only 3-10 digits and letters are allowed.");
                }

                else
                    loopReg = false;


            } while (loopReg == true);
            return regNumber;

        }

        internal DateTime CheckInTime()
        {
            DateTime createTime = DateTime.Now;
            return createTime;
        }



        internal VehicleEnum CreateVehicleType()
        {

            Console.WriteLine("\nIs your vehicle a Car or MC");

            string input = Console.ReadLine();
            input = input.ToUpper();

            if (input == "CAR")
                return VehicleEnum.Car;

            else if (input == "MC")
            {
                return VehicleEnum.MC;
            }

            else
            {
                Console.WriteLine("Wrong input, only MC or Car are allowed. Try again.");
                return CreateVehicleType();
            }
        }

        internal Vehicle CreateVehicle(string reg, DateTime vehDate, VehicleEnum type)
        {

            Vehicle creVeh = new Vehicle(reg, vehDate, type);
            return creVeh;
        }

    }
}
