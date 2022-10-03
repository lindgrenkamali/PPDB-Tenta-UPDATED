using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PPDBDavidLindgrenKamaliBackEnd
{

        public static class SQLMetoder
        {

        public static SqlConnection CreateSQL()
        {
            SqlConnection con = new SqlConnection("Data Source=localhost\\SQLEXPRESS; Initial Catalog=PPDBDavidLindgrenKamali; Integrated Security=SSPI");

            return con;
        }

        public static string InsertVehicle(string regNumber, DateTime vehicleTime, VehicleProperties.VehicleEnum theVehicleType)
        {
            string inputReg = regNumber;
            DateTime inputTime = vehicleTime;
            int vehicleType = (int)theVehicleType;


            try
            {
                SqlConnection con = CreateSQL();
                using (con)
                {
                    con.Open();


                    SqlCommand insCMD = new SqlCommand("Add_Vehicle", con);
                    insCMD.CommandType = CommandType.StoredProcedure;
                    insCMD.Parameters.AddWithValue("@Regnumber", inputReg);
                    insCMD.Parameters.AddWithValue("@VehicleSize", vehicleType);
                    insCMD.Parameters.AddWithValue("@VehicleTime", inputTime);
                    var returnValue = insCMD.Parameters.Add("@ParkingLot", SqlDbType.Int);
                    returnValue.Direction = ParameterDirection.ReturnValue;


                    insCMD.ExecuteNonQuery();

                    if ((int)returnValue.Value == 0)
                    {
                        return $"The vehicle with REGNUMBER: {inputReg} couldn't be added, since there already exist one with the same REGNUMBER.";
                    }

                    else if ((int)returnValue.Value == -1)
                    {
                        return $"The vehicle couldn't be added since all parkinglots are filled.";
                    }

                    else
                    {
                        return $"Vehicle with REGNUMBER {inputReg} has been added to Parkinglot {(int)returnValue.Value}";
                    }

                }
            }
            catch(Exception ex)
            {
                return $"There was a problem with the database: {ex}";
            }

        }

        public static string DeleteVehicle(string inputReg)
        {

            SqlConnection con = CreateSQL();

            try
            {

                using (con)
                {
                    con.Open();
                    SqlCommand insCMD = new SqlCommand("Delete_Vehicle", con);
                    insCMD.CommandType = CommandType.StoredProcedure;
                    insCMD.Parameters.AddWithValue("@Regnumber", inputReg);
                    var returnValue = insCMD.Parameters.Add("@ParkingLot", SqlDbType.Int);
                    returnValue.Direction = ParameterDirection.ReturnValue;
                    insCMD.ExecuteNonQuery();
                    string[] stringArray = new string[7];

                    if ((int)returnValue.Value == 0)
                    {
                        return $"The vehicle {inputReg} didn't exist and hasn't been checked out.";
                    }

                    else
                    {
                        SqlCommand vehicleReceipt = new SqlCommand("Top1_ParkingHistory", con);
                        vehicleReceipt.CommandType = CommandType.StoredProcedure;
                        vehicleReceipt.Parameters.AddWithValue("@Regnumber", inputReg);

                        SqlDataReader reader = vehicleReceipt.ExecuteReader();

                        using (reader)
                        {
                            while (reader.Read())
                            {
                                stringArray[0] = reader.GetInt32(0).ToString();
                                stringArray[1] = reader.GetString(1);
                                stringArray[2] = reader.GetString(2);
                                stringArray[3] = reader.GetDateTime(3).ToString();
                                stringArray[4] = reader.GetDateTime(4).ToString();
                                stringArray[5] = reader.GetInt32(5).ToString();
                                stringArray[6] = reader.GetInt32(5).ToString();
                            }

                            return $"ReceiptID: {stringArray[0]}\nREGNUMBER: {stringArray[1]}\nVehicleType: {stringArray[2]}\nCheckIn Time: {stringArray[3]}\n" +
                               $"CheckOut Time: {stringArray[4]}\nHours Parked: {stringArray[5]}\nTotal Cost: {stringArray[6]}\n";

                        }
                    }
                }
            }
            catch (Exception ex)
            {
                return $"There was a problem with the database: {ex}";
            }

        }

        public static string MoveVehicle(string inputReg, int ParkLotPosition)
        {
            SqlConnection con = CreateSQL();
            try
            {
                using (con)
                {
                    con.Open();
                    SqlCommand insCMD = new SqlCommand("Move_Vehicle", con);
                    insCMD.CommandType = CommandType.StoredProcedure;
                    insCMD.Parameters.AddWithValue("@Regnumber", inputReg);
                    insCMD.Parameters.AddWithValue("@InputParkinglot", ParkLotPosition);
                    var returnValue = insCMD.Parameters.Add("@Output", SqlDbType.Int);
                    returnValue.Direction = ParameterDirection.ReturnValue;
                    insCMD.ExecuteNonQuery();

                    if ((int)returnValue.Value == 0)
                    {
                        return $"The vehicle with REGNUMBER {inputReg} did not exist";
                    }
                    else if ((int)returnValue.Value == -1)
                    {
                        return $"The vehicle {inputReg} did not fit in parkinglot {ParkLotPosition} and hasn't been moved";
                    }
                    else
                    {
                        return $"The vehicle with REGNUMBER {inputReg} has been moved from parkinglot {returnValue.Value} to {ParkLotPosition}";
                    }
                }
            }
            catch (Exception ex)
            {
                return $"There was a problem with the database: {ex}";
            }
        }


        public static string[] AllVehicles()
        {
            SqlConnection con = CreateSQL();
            using (con)
            {
                string[] output = new string[8];
                string[] outputArray = new string[200];
                int rdrCounter = 0;

                con.Open();
                SqlCommand insCMD = new SqlCommand("All_Vehicles", con);
                insCMD.CommandType = CommandType.StoredProcedure;


                SqlDataReader reader = insCMD.ExecuteReader();
                string[] searchedVehicle = new String[7];

                using (reader)
                {
                    while (reader.Read())
                    {

                        searchedVehicle[0] = reader.GetInt32(0).ToString();
                        searchedVehicle[1] = reader.GetString(1);
                        searchedVehicle[2] = reader.GetDateTime(2).ToString();
                        searchedVehicle[3] = reader.GetString(3);
                        searchedVehicle[4] = reader.GetInt32(4).ToString();
                        searchedVehicle[5] = reader.GetInt32(5).ToString();
                        searchedVehicle[6] = reader.GetInt32(6).ToString();

                        outputArray[rdrCounter] = $"ParkinglotID: {searchedVehicle[0]}\nREG: {searchedVehicle[1]}\n" +
                        $"VehicleType: {searchedVehicle[3]}\nCheckInTime {searchedVehicle[2]}\nHours parked: {searchedVehicle[4]}\nPrice per hour: {searchedVehicle[5]} kr\nCurrent Cost: {searchedVehicle[6]} kr\n";
                        rdrCounter++;
                    }
                    return outputArray;
                }

            }
        }

        public static string SearchVehicle(string inputReg)
        {
            try
            {

                SqlConnection con = CreateSQL();
                using (con)
                {
                    con.Open();
                    SqlCommand insCMD = new SqlCommand("Search_Vehicle", con);
                    insCMD.CommandType = CommandType.StoredProcedure;
                    insCMD.Parameters.AddWithValue("@Regnumber", inputReg);
                    string result;

                    SqlDataReader reader = insCMD.ExecuteReader();
                    string[] searchedVehicle = new String[7];

                    using (reader)
                    {
                        while (reader.Read())
                        {
                            if (string.IsNullOrEmpty(reader.GetString(1)) != true)
                            {

                                searchedVehicle[0] = reader.GetInt32(0).ToString();
                                searchedVehicle[1] = reader.GetString(1);
                                searchedVehicle[2] = reader.GetString(2);
                                searchedVehicle[3] = reader.GetDateTime(3).ToString("");
                                searchedVehicle[4] = reader.GetInt32(4).ToString();
                                searchedVehicle[5] = reader.GetInt32(5).ToString();
                                searchedVehicle[6] = reader.GetInt32(6).ToString();

                                return result = $"ParkinglotID: {searchedVehicle[0]}\nREG: {searchedVehicle[1]}\nVehicleType: {searchedVehicle[2]}\n" +
                                    $"CheckInTime: {searchedVehicle[3]}\nHours parked: {searchedVehicle[4]}\nPrice per hour: {searchedVehicle[5]}\nCurrent Cost: {searchedVehicle[6]}\n";
                            }
                        }
                    }

                    return result = "No vehicle with that REGNUMBER exists";
                }
            }
            catch (Exception ex)
            {
                return $"There was a problem with the database: {ex}";
            }
        }

        public static List<string> ParkingHistorySearch(string inputReg)
        {
            SqlConnection con = CreateSQL();
            using (con)
            {

                string[] stringArray = new string[7];
                List<string> stringReturnList = new List<string>();
                con.Open();
                SqlCommand insCMD = new SqlCommand("Parking_History", con);
                insCMD.CommandType = CommandType.StoredProcedure;
                insCMD.Parameters.AddWithValue("@Regnumber", inputReg);
                SqlDataReader reader = insCMD.ExecuteReader();
                using (reader)
                {
                    while (reader.Read())
                    {
                        stringArray[0] = reader.GetInt32(0).ToString();
                        stringArray[1] = reader.GetString(1);
                        stringArray[2] = reader.GetString(2);
                        stringArray[3] = reader.GetDateTime(3).ToString();
                        stringArray[4] = reader.GetDateTime(4).ToString();
                        stringArray[5] = reader.GetInt32(5).ToString();
                        stringArray[6] = reader.GetInt32(6).ToString();
                        string tempParkHistory = $"HistoryID: {stringArray[0]}\nREGNUMBER: {stringArray[1]}\nVehicleType: {stringArray[2]}\nVehicle CheckIn Time: {stringArray[3]}\nVehicle CheckOut Time: {stringArray[4]}\nHours Parked: {stringArray[5]}\nCost: {stringArray[6]}";

                        stringReturnList.Add(tempParkHistory);
                    }

                    return stringReturnList;

                }
            }
        }


        public static string[] EmptyParkingLots()
        {

            string[] stringArray = new string[2];
            string[] stringReturnArray = new string[100];
            int rdrCounter = 0;
            try
            {
                SqlConnection con = CreateSQL();
                using (con)
                {
                    con.Open();
                    SqlCommand insCMD = new SqlCommand("Search_EmptyParkinglots", con);
                    insCMD.CommandType = CommandType.StoredProcedure;
                    SqlDataReader reader = insCMD.ExecuteReader();
                    using (reader)
                    {
                        while (reader.Read())
                        {
                            stringArray[0] = reader.GetInt32(0).ToString();
                            stringArray[1] = reader.GetInt32(1).ToString();

                            if (stringArray[1] == "0")
                            {
                                stringReturnArray[rdrCounter] = $"{stringArray[0]} has place for 1 Car or 2 MC";
                            }
                            else if (stringArray[1] == "1")
                            {
                                stringReturnArray[rdrCounter] = $"{stringArray[0]} has place for 1 MC";
                            }
                            else
                            {
                                stringReturnArray[rdrCounter] = $"{stringArray[0]} has currently no place for a vehicle";
                            }

                            rdrCounter++;
                        }

                        return stringReturnArray;

                    }
                }

            }
            catch
            {
                stringReturnArray[0] = "-1";
                return stringReturnArray;

            }
        }
    }
}

