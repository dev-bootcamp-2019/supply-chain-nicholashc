pragma solidity ^0.4.13;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";

contract TestSupplyChain {

    //start with some ether
    uint public initialBalance = 1 ether;

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
    function testOnlyOwnerModifier() public {
      //instatiate contracts
      SupplyChain s = new SupplyChain();
      ProxyTester p = new ProxyTester();
      //declare expected value
      bool expected = true;
      //test assertion
      Assert.equal(s.accessByOwner(), expected, "msg.sender should be the owner");
      //call via proxy; should return false
      bool proxyCallResult = p.accessByOwnerProxy(s);
      Assert.isFalse(proxyCallResult, "accessByOwner() should throw an exception when called by non-owner");
    }

    //test that verify caller works in shipItem
    //note: counterfactural covered in testShipItemNotFromSeller()
    //note: this also tests sold modifier
    function testVerifyCallerModifier() public {
      //instatiate contracts
      SupplyChain s = new SupplyChain();
      ProxyTester p = new ProxyTester();
      //add item
      s.addItem("first item", 100);
      //buy via proxy
      p.buyProxy.value(100)(s);
      //attempt to ship item
      bytes memory functionSignature = padFunctionWithOneByteArgument("shipItem(uint256)", 0x00);
      bool attemptedShipCall = address(s).call(functionSignature);
      //check assetion
      Assert.isTrue(attemptedShipCall, "shipItem() should not throw an exception");
    }

    //note: this also tests forSale modifie
    function testPaidEnoughModifier() public {
      //instatiate contracts
      SupplyChain s = new SupplyChain();
      ProxyTester p = new ProxyTester();
      //add via proxy
      p.addProxy(s);
      //attempt to buy item with exact price
      bytes memory functionSignature = padFunctionWithOneByteArgument("buyItem(uint256)", 0x00);
      bool attemptedBuyCall = address(s).call.value(100)(functionSignature);
      //check assetion
      Assert.isTrue(attemptedBuyCall, "buyItem() should not throw an exception");
    }

    function testCheckValueModifier() public {
      //instatiate contracts
      SupplyChain s = new SupplyChain();
      ProxyTester p = new ProxyTester();
      //add via proxy
      p.addProxy(s);
      //attempt to buy item with more than price (excess should be returned)
      bytes memory functionSignature = padFunctionWithOneByteArgument("buyItem(uint256)", 0x00);
      bool attemptedBuyCall = address(s).call.value(200)(functionSignature);
      //check assetion
      Assert.isTrue(attemptedBuyCall, "buyItem() should not throw an exception");
    }

    function testReceivedModifier() public {
      //instatiate contracts
      SupplyChain s = new SupplyChain();
      ProxyTester p = new ProxyTester();
      //add via proxy
      p.addProxy(s);
      //buy
      s.buyItem.value(100)(0);
      //ship proxy
      p.shipProxy(s);
      //attempt to mark item as received
      bytes memory functionSignature = padFunctionWithOneByteArgument("receiveItem(uint256)", 0x00);
      bool attemptedReceiveCall = address(s).call(functionSignature);
      //check assetion
      Assert.isTrue(attemptedReceiveCall, "receiveItem() should not throw an exception");
    }

    // buyItem
    // test for failure if user does not send enough funds
    function testItemPurchaseWithInsufficientFunds() public {
      //instatiate
      SupplyChain s = new SupplyChain();
      //add item
      s.addItem("first item", 100);
      //attempt to call buy item
      bytes memory functionSignature = padFunctionWithOneByteArgument("buyItem(uint256)", 0x00);
      bool attemptedBuyCall = address(s).call.value(99)(functionSignature);
      //check assetion
      Assert.isFalse(attemptedBuyCall, "buyItem() should throw an exception");
    }

    // test for purchasing an item that is not for Sale
    function testItemPurchaseWhenNotForSale() public {
      //instatiate contracts 
      SupplyChain s = new SupplyChain();
      ProxyTester p = new ProxyTester();
      //add item
      s.addItem("first item", 100);
      //buy via proxy
      p.buyProxy.value(100)(s);
      //attempt to call buy item on same item
      bytes memory functionSignature = padFunctionWithOneByteArgument("buyItem(uint256)", 0x00);
      bool attemptedBuyCall = address(s).call.value(100)(functionSignature);
      //check assetion
      Assert.isFalse(attemptedBuyCall, "buyItem() should throw an exception");
    }

    // shipItem
    // test for calls that are made by not the seller
    function testShipItemNotFromSeller() public {
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
    function testShipItemNotYetSold() public {
      //instatiate
      SupplyChain s = new SupplyChain();
      //add item
      s.addItem("first item", 100);
      //attempt to ship item
      bytes memory functionSignature = padFunctionWithOneByteArgument("shipItem(uint256)", 0x00);
      bool attemptedShipCall = address(s).call(functionSignature);
      //establish expected value
      (,,,uint expected,,) = s.fetchItem(0); //expected state == 0 == State.ForSale
      //check assetions
      Assert.isFalse(attemptedShipCall, "shipItem() should throw an exception");
      Assert.equal(0, expected, "the state should be ForSale");
    }

    // receiveItem
    // test calling the function from an address that is not the buyer
    function testReceiveItemNotFromBuyer() public {
      //instatiate contracts
      SupplyChain s = new SupplyChain();
      ProxyTester p = new ProxyTester();
      //add an item
      s.addItem("first item", 100);
      //buy and ship item with ProxyTester
      p.buyProxy.value(100)(s);
      //ship item
      s.shipItem(0);
      //attempt to call receive item
      bytes memory functionSignature = padFunctionWithOneByteArgument("receiveItem(uint256)", 0x00);
      bool attemptedReceiveCall = address(s).call(functionSignature);
      //check assetion
      Assert.isFalse(attemptedReceiveCall, "receiveItem() should throw an exception");
    }

    // test calling the function on an item not marked Shipped
    function testReceiveItemNotYetShipped() public {
      //instatiate
      SupplyChain s = new SupplyChain();
      ProxyTester p = new ProxyTester();
      //add item via proxy
      p.addProxy(s);
      //buy item
      s.buyItem.value(100)(0);
      //attempt to call receive item
      bytes memory functionSignature = padFunctionWithOneByteArgument("receiveItem(uint256)", 0x00);
      bool attemptedReceiveCall = address(s).call(functionSignature);
      //check assetion
      Assert.isFalse(attemptedReceiveCall, "receiveItem() should throw an exception");
    }

    //utility function to encode function signature 
    function calcFunctionSignature(string _sig) public pure returns (bytes) {
      return abi.encodeWithSignature(_sig);
    }

    //utility function to pad function signatures with arguments 
    function padFunctionWithOneByteArgument(string _sig, bytes1 _arg) public pure returns (bytes) {
      bytes31 padding31bytes = 0x00000000000000000000000000000000000000000000000000000000000000;
      return abi.encodePacked(calcFunctionSignature(_sig), padding31bytes, _arg); 
    }

    //contract should be able to receive ether
    function() public payable {}

}

contract ProxyTester {

  function addProxy(address _s) public {
    //instatiate contract from address passed 
    SupplyChain s = SupplyChain(_s);
    //call add
    s.addItem("first item", 100);
  }

  function buyProxy(address _s) public payable {
    //instatiate contract from address passed 
    SupplyChain s = SupplyChain(_s);
    //call buy
    s.buyItem.value(100)(0);
  }

  function shipProxy(address _s) public {
    //instatiate contract from address passed 
    SupplyChain s = SupplyChain(_s);
    //call ship
    s.shipItem(0);
  }

  function accessByOwnerProxy(address _s) public returns(bool){
    //instatiate contract from address passed 
    SupplyChain s = SupplyChain(_s);
    //call accessByOwner
    bytes memory functionSignature = abi.encodeWithSignature("accessByOwner()");
    //bubble up call value 
    return address(s).call(functionSignature);
  }

  //contract should be able to receive ether
  function() public payable {}
}
