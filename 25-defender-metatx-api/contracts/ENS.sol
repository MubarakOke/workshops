// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "@openzeppelin/contracts/metatx/ERC2771Forwarder.sol";

contract ENS is ERC2771Context{
    struct Profile {
        string userName;
        address userAddress;
        string imageUri;
    }
    mapping(address => mapping (string => Profile)) details;
    mapping(address => string) addressToName;
    mapping(string => address) nameToAddress;

    constructor(ERC2771Forwarder forwarder) ERC2771Context(address(forwarder)) {
    }

    function setDetail(string calldata _name, string calldata _imageUri) public {
        
        require(details[_msgSender()][_name].userAddress == address(0), "Name already exists");

        Profile memory newProfile= Profile(_name, _msgSender(), _imageUri);

        details[_msgSender()][_name] = newProfile;

        addressToName[_msgSender()] = _name;
        nameToAddress[_name] = _msgSender();
    }

    function getDetailsAddressFromName(string calldata _name) public view returns (Profile memory) {
        address userAdress= getAddressFromName(_name);
        require(userAdress != address(0), "Name already exists");

        return details[userAdress][_name];
    }

    function getAddressFromName(string calldata _name) public view returns (address) {
        return nameToAddress[_name];
    }

    function getNameFromAddress(address _address) public view returns (string memory) {
        return addressToName[_address];
    }
}
