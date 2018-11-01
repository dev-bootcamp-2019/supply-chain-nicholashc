pragma solidity ^0.4.23;

contract SupplyChain {

  /* set owner */
  address public owner;

  /* Add a variable called skuCount to track the most recent sku # */
  uint128 public skuCount;

  /* Add a line that creates a public mapping that maps the SKU (a number) to an Item.
     Call this mappings items
  */
  mapping (uint => Item) public items;

  /* Add a line that creates an enum called State. This should have 4 states
    ForSale
    Sold
    Shipped
    Received
    (declaring them in this order is important for testing)
  */
  enum State { ForSale, Sold, Shipped, Received }

  /* Create a struct named Item.
    Here, add a name, sku, price, state, seller, and buyer
    We've left you to figure out what the appropriate types are,
    if you need help you can ask around :)
  */
  struct Item {
    //@note: tightly-packed bit values to use one less storage slot
    uint128 sku; 
    uint128 price;
    string name;
    State state;
    address seller;
    address buyer;
  }

  /* Create 4 events with the same name as each possible State (see above)
    Each event should accept one argument, the sku*/
  event ForSale(uint sku);
  event Sold(uint sku);
  event Shipped(uint sku);
  event Received(uint sku);

  /* Create a modifier that checks if the msg.sender is the owner of the contract */
  modifier onlyOwner () { 
    require (msg.sender == owner, "only the owner can access this function"); 
    _; 
  }

  modifier verifyCaller (address _address) { 
    require (msg.sender == _address, "invalid caller"); 
    _;
  }

  modifier paidEnough(uint _price) { 
    require(msg.value >= _price, "insufficient amount"); 
    _;
  }

  modifier checkValue(uint _sku) {
    //refund them after pay for item (why it is before, _ checks for logic before func)
    _;
    uint _price = items[_sku].price;
    uint amountToRefund = msg.value - _price;
    items[_sku].buyer.transfer(amountToRefund);
  }

  /* For each of the following modifiers, use what you learned about modifiers
   to give them functionality. For example, the forSale modifier should require
   that the item with the given sku has the state ForSale. */
  modifier forSale(uint _sku) {
    require (items[_sku].state == State.ForSale, "this item must be for sale"); 
    _;
  }

  modifier sold(uint _sku) {
    require (items[_sku].state == State.Sold, "this item must be sold"); 
    _;
  }

  modifier shipped(uint _sku) {
    require (items[_sku].state == State.Shipped, "this item must be shipped"); 
    _;
  }

  modifier received(uint _sku) {
    require (items[_sku].state == State.Received, "this item must be received"); 
    _;
  }


  constructor() public {
    /* Here, set the owner as the person who instantiated the contract
       and set your skuCount to 0. */
    owner = msg.sender;
    skuCount = 0; //skuCount is already 0, but just in case...
  }

  function addItem(string _name, uint128 _price) public {
    emit ForSale(skuCount);
    items[skuCount] = Item({name: _name, sku: skuCount, price: _price, state: State.ForSale, seller: msg.sender, buyer: 0});
    skuCount = skuCount + 1;
  }

  /* Add a keyword so the function can be paid. This function should transfer money
    to the seller, set the buyer as the person who called this transaction, and set the state
    to Sold. Be careful, this function should use 3 modifiers to check if the item is for sale,
    if the buyer paid enough, and check the value after the function is called to make sure the buyer is
    refunded any excess ether sent. Remember to call the event associated with this function!*/
  function buyItem(uint sku)
    public
    payable
    forSale(sku)
    paidEnough(msg.value)
    checkValue(sku)
  {
    //instantiate struct in storage
    Item storage i = items[sku];
    //change state
    i.buyer = msg.sender;
    i.state = State.Sold;
    //transfer to seller
    //@note the sale could be dos-ed if the seller was a smart contract. push/pull withdraw pattern would be safer 
    i.seller.transfer(i.price); 
    //emit event
    emit Sold(sku);
  }

  /* Add 2 modifiers to check if the item is sold already, and that the person calling this function
  is the seller. Change the state of the item to shipped. Remember to call the event associated with this function!*/
  function shipItem(uint sku)
    public
    sold(sku)
    verifyCaller(items[sku].seller)
  {
    //instantiate struct in storage
    Item storage i = items[sku];
    //change state
    i.state = State.Shipped;
    //emit event
    emit Shipped(sku);
  }

  /* Add 2 modifiers to check if the item is shipped already, and that the person calling this function
  is the buyer. Change the state of the item to received. Remember to call the event associated with this function!*/
  function receiveItem(uint sku)
    public
    shipped(sku)
    verifyCaller(items[sku].buyer)
  {
    //instantiate struct in storage
    Item storage i = items[sku];
    //change state
    i.state = State.Received;
    //emit event
    emit Received(sku);
  }

  /* We have these functions completed so we can run tests, just ignore it :) */
  function fetchItem(uint _sku) public view returns (string name, uint sku, uint price, uint state, address seller, address buyer) {
    name = items[_sku].name;
    sku = items[_sku].sku;
    price = items[_sku].price;
    state = uint(items[_sku].state);
    seller = items[_sku].seller;
    buyer = items[_sku].buyer;
    return (name, sku, price, state, seller, buyer);
  }

  //function to test onlyOwner modifier
  function accessByOwner() public view onlyOwner() returns(bool) {
    //will only return if modifier conditions are met 
    return true;
  }

}
