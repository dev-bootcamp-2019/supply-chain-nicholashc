pragma solidity ^0.4.13;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";

contract TestSupplyChain {

    //establish tests are working correctly and test initial sku count 
    function testInitialSkuCount() public {
      //instantiate contract 
      SupplyChain s = SupplyChain(DeployedAddresses.SupplyChain());
      //declare expected value
      uint expected = 0;
      //test assertion
      Assert.equal(s.skuCount(), expected, "skuCount should start at 0");
    }

    //test if sku count increments correctly 
    function testSkuCountAfterBuy() public {
      //instantiate contract 
      SupplyChain s = new SupplyChain();
      //add item
      s.addItem("first item", 100);
      //declare expected value
      uint expected = 1;
      //test assertion
      Assert.equal(s.skuCount(), expected, "skuCount should be 1");
    }

    // Test for failing conditions in this contracts
    // test that every modifier is working
    function testOnlyOwnerModifier() {
      //instatiate contract
      SupplyChain s = new SupplyChain();
      //declare expected value
      bool expected = true;
      //test assertion
      Assert.equal(s.accessByOwner(), expected, "msg.sender should be the owner");
      //@nhc how do i test if this is false by sending from another address?
    }

    // function testVerifyCallerModifier() {
    //   //instatiate
    //   SupplyChain s = new SupplyChain();
    //   //test logic
    // }

    // function testPaidEnoughModifier() {
    //   //instatiate
    //   SupplyChain s = new SupplyChain();
    //   //test logic
    // }

    // function testCheckValueModifier() {
    //   //instatiate
    //   SupplyChain s = new SupplyChain();
    //   //test logic
    // }

    // function testForSaleModifier() {
    //   //instatiate
    //   SupplyChain s = new SupplyChain();
    //   //test logic
    // }

    // function testSoldModifier() {
    //   //instatiate
    //   SupplyChain s = new SupplyChain();
    //   //test logic
    // }

    // function testShipperModifier() {
    //   //instatiate
    //   SupplyChain s = new SupplyChain();
    //   //test logic
    // }

    // function testReceivedModifier() {
    //   //instatiate
    //   SupplyChain s = new SupplyChain();
    //   //test logic
    // }

    // // buyItem

    // // test for failure if user does not send enough funds
    // function testItemPurchaseWithInsufficientFunds() {
    //   //instatiate
    //   SupplyChain s = new SupplyChain();
    //   //add item
    //   s.addItem("first item", 100);
    //   //test logic
    //   uint expected = item[0].price;

    //   Assert.equal(s.buyItem.value(99)(0), expected, "Owner should have 10000 MetaCoin initially");
    // }
    // // test for purchasing an item that is not for Sale
    // function testItemPurchaseWhenNotForSale() {
    //   //instatiate
    //   SupplyChain s = new SupplyChain();
    //   //test logic
    // }

    // shipItem

    // // test for calls that are made by not the seller
    // function testShipItemNotFromSeller() {
    //   //instatiate
    //   SupplyChain s = new SupplyChain();
    //   //add item
    //   s.addItem("first item", 100);
    //   //test logic
    //   address foo = s.items[0].sender; //@nhc how can I access values in a struct?
    //   //check assertion 
    //   //Assert.equal(this, expected, "msg.sender should be the sender");
    // }
    // // test for trying to ship an item that is not marked Sold
    // function testShipItemNotYetSold() {
    //   //instatiate
    //   SupplyChain s = new SupplyChain();
    //   //test logic
    // }

    // // receiveItem

    // // test calling the function from an address that is not the buyer
    // function testReceiveItemNotFromBuyer() {
    //   //instatiate
    //   SupplyChain s = new SupplyChain();
    //   //test logic
    // }
    // // test calling the function on an item not marked Shipped
    // function testReceiveItemNotYetShipped() {
    //   //instatiate
    //   SupplyChain s = new SupplyChain();
    //   //test logic

    // }

}
