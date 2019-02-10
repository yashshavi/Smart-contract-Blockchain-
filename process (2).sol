pragma solidity ^0.4.17;

//property fectory create new instances of property contract and return 
//deployed property contract

contract propertyfectory { 
 
   address[] public deployedproperties;

  //create instance of new property

 function createnew(uint sellingprice) public {
    address newproperty = new Property(sellingprice, msg.sender);
    deployedproperties.push(newproperty);

}

 //get list of all property 
 function getdeployedproperties() public view returns (address[]){
     return deployedproperties;
   }


}


           //seller-buyer interaction through Property contract

contract  Property {
 //structure for storing info when buyer reserves a property

    struct BuyerRequest {
         string request;
         uint price; 
         address self;
   }


    BuyerRequest[] public requests; // instance of request     
    address public seller_broker; // seller broker address
    uint  public sp;// selling price
    bool public complete; 
    bool public signofseller;
    bool public signofbuyer;
    string public ipfsHash;//boolean to denote process is complete or not  
    mapping(address => bool) public sellersaid;//seller final answer
    mapping(address => bool) public buyer; //to store approved buyer
    mapping(address => bool) public buyersaid;// buyer final answer
     
    function Property(uint selling_price, address creator) public {
       require(!complete);
       seller_broker = creator;
       sp = selling_price; 
    }
   
     
    function sendRequest(string re,uint pr, address by) public  {
       require( msg.sender == by);
       require(!complete);
       require(pr>=sp);
       BuyerRequest memory newBuyerRequest = BuyerRequest({
           request: re,
           price:pr,
           self: by
           
       });
       requests.push(newBuyerRequest);
    }
    
     function getallrequest() public view returns(BuyerRequest[]) {
        require(!complete);
       return requests;
        
    }
    
    
    
    
   function approveRequest(uint index) public restricted{
         require(!buyer[requests[index-1].self]);
         require(!complete);
         buyer[requests[index-1].self]=true;
         
   }
     
   
    
    
   
    
    function sendHash(string x,address bu) public{
        require(msg.sender==seller_broker);
        require(!complete);
        require(buyer[bu]);
        ipfsHash = x;
        
        
    }
   function signofseller(address sender)  public{
        require(msg.sender==seller_broker);
        require(!complete);
        signofseller=true;        
   }

   function getHash(address bu) public view returns (string x) {
     require(msg.sender==bu);
     require(!complete);
     require(buyer[bu]);
     
   return ipfsHash;
 }
  function signofbuyer(address bu) public
  {
      require(msg.sender==bu);
      signofbuyer=true;
  }
  
   function payment(address bu) public payable{
        require(msg.sender== bu);
        require(msg.value == sp);
        require(!complete);
        require(buyer[bu]);
        require(signofbuyer);
        require(signofseller);
        seller_broker.transfer(msg.value);
        complete=true;
    }
   modifier restricted(){
       require(msg.sender==seller_broker);
       _;
   }

 }   

