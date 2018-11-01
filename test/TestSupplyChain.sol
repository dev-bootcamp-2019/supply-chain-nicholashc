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

    // test for calls that are made by not the seller
    function testShipItemNotFromSeller() {
      //instatiate
      SupplyChain s = new SupplyChain();
      //add item
      s.addItem("first item", 100);
      //establish expected address (deconstructed tuple required here) 
      (,,,,address expected,) = s.fetchItem(0); 
      //check assertion 
      Assert.equal(address(this), expected, "msg.sender should be the sender");
    }

    // test for trying to ship an item that is not marked Sold
    function testShipItemNotYetSold() {
      //instatiate
      SupplyChain s = new SupplyChain();
      //add item
      s.addItem("first item", 100);
      //attempt to ship item
      bytes memory functionSignature = padFunctionWithOneByteArgument("shipItem(uint256)", 0x00);
      bool attemptedShip = s.call(functionSignature);
      //establish expected value
      (,,,uint expected,,) = s.fetchItem(0); //expected state == 0 == State.ForSale
      //check assetions
      Assert.isFalse(attemptedShip, "shipItem() should fail");
      Assert.equal(0, expected, "the state should be ForSale");
    }

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

    //utility function to encode function signature 
    function calcFunctionSignature(string _sig) internal pure returns (bytes4) {
      return bytes4(keccak256(abi.encodePacked(_sig)));
    }

    function padFunctionWithOneByteArgument(string _sig, bytes1 _arg) internal pure returns (bytes) {
      bytes31 padding31bytes = 0x00000000000000000000000000000000000000000000000000000000000000;
      return abi.encodePacked(calcFunctionSignature(_sig), padding31bytes, _arg); 
    }

}

contract proxyTester {

    //add logic to call SupplyChain.sol from another address 

}
