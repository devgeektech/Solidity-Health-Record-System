// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;


contract HealthRecordSystem
{
   struct RegDoctor{
        uint id;
        string name;
        string qualification;
        string workPlace;
   }
   RegDoctor Regdoctor;

   function RegisterDoctor(uint _id,string memory _name, string memory _qualification, string memory _workPlace) public 
    {
             Regdoctor.id=_id;
             Regdoctor.name=_name;
             Regdoctor.qualification=_qualification;
             Regdoctor.workPlace=_workPlace;
    }
   function ViewRegisterDoctor(uint _id) public view returns(uint ,string memory , string memory , string memory ) {
     
     return (Regdoctor.id,Regdoctor.name,Regdoctor.qualification, Regdoctor.workPlace);

   }

}
