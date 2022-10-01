using System;
using System.Collections.Generic;

namespace PPDBDavidLindgrenKamaliFrontEnd
{
    class Program
    {
        private static void Main(string[] args)
        {
            ADOMetoder adoAdd = new ADOMetoder();
            Menu(adoAdd);

        }


        private static void Menu(ADOMetoder ado)
        {

            bool looping = true;

            //Val i menyn
            string Choice;
            string stringOutput;
            string[] arrayOutput = new string[100];
            List<string> listOutput = new List<string>();
            string regInput;

            Console.WriteLine("Welcome to some ParkingLot.");

            do
            {

                Console.WriteLine("\nPress 1: Add vehicle.");
                Console.WriteLine("Press 2: Remove vehicle.");
                Console.WriteLine("Press 3: Move vehicle.");
                Console.WriteLine("Press 4: Search for vehicle.");
                Console.WriteLine("Press 5: Print all vehicles.");
                Console.WriteLine("Press 6: Print out empty parkinglots.");
                Console.WriteLine("Press 7: Search for vehicle parkhistory.");
                Console.WriteLine("Press 8: Quit program.\n");
                Choice = Console.ReadLine();
                switch (Choice)
                {
                    case "1":
                        Console.Clear();
                        regInput = ado.RegNumber();
                        stringOutput = ado.AddVehicle(regInput);
                        Console.WriteLine(stringOutput);
                        break;

                    case "2":
                        Console.Clear();
                        regInput = ado.RegNumber();
                        stringOutput = ado.DeleteVehicle(regInput);
                        Console.WriteLine(stringOutput);
                        break;


                    case "3":
                        Console.Clear();
                        stringOutput = ado.MoveVehicle();
                        Console.WriteLine(stringOutput);
                        break;


                    case "4":
                        Console.Clear();
                        stringOutput = ado.SearchVehicle();
                        Console.WriteLine(stringOutput);
                        break;

                    case "5":
                        Console.Clear();
                        arrayOutput = ado.ParkedVehicles();

                        foreach (var vehicle in arrayOutput)
                        {
                            if (vehicle == null)
                            {
                                break;
                            }

                            else
                            {
                                Console.WriteLine(vehicle.ToString());
                            }
                        }

                        break;

                    case "6":
                        Console.Clear();
                        arrayOutput = ado.NotFullParkinglot();
                        if (arrayOutput[0] == "-1")
                        {
                            Console.WriteLine("There was an error with the database");
                        }

                        else
                        {



                            foreach (var vehicle in arrayOutput)
                            {
                                if (vehicle != null)
                                {
                                    Console.WriteLine(vehicle.ToString());
                                }

                            }
                        }
                        break;

                    case "7":
                        Console.Clear();
                        listOutput = ado.ParkingHistory();
                        if (listOutput.Count > 0)
                        {
                            foreach (var parkhistory in listOutput)
                            {
                                Console.WriteLine(parkhistory);
                            }
                        }

                        else
                        {
                            Console.WriteLine("No vehicle has checked out with that REGNUMBER.");
                        }
                        break;

                    case "8":
                        Console.Clear();
                        Console.WriteLine("The program will no exit");
                        looping = false;
                        break;


                    default:
                        Console.WriteLine("Wrong input");
                        break;
                }
            } while (looping == true);
        }
    }
}
