using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace PPDBDavidLindgrenKamaliBackEnd.VehicleProperties
{
    public class Vehicle
    {

        internal VehicleEnum theVehicleType
        {
            get;

        }

        internal DateTime VehicleTime
        {
            get;
        }

        internal string RegNumber
        {
            get;
        }

        public Vehicle(string regNumber, DateTime vehicleTime, VehicleEnum vehicleType)
        {
            this.RegNumber = regNumber;
            this.VehicleTime = vehicleTime;
            this.theVehicleType = vehicleType;

        }

    }
}
