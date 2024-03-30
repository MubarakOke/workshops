// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IENS.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "@openzeppelin/contracts/metatx/ERC2771Forwarder.sol";

contract Chat is ERC2771Context {
    IENS ens;
    uint256 chatId;

    constructor(address ENS, ERC2771Forwarder forwarder) ERC2771Context(address(forwarder)) {
        ens = IENS(ENS);
    }

    event MessageSent(
        string indexed sender,
        string indexed receiver,
        string message
    );

    struct Message {
        uint256 timestamp;
        string message;
        string receiver;
        string sender;
    }

    struct Profile {
        string name;
        bool registered;
    }

    mapping(address => mapping(address => uint256)) chatsIds;
    mapping(uint256 => Message[]) chats;
    mapping(address => string[]) conversationList;
    mapping(address => mapping(address => bool)) conversationListMapping;

    mapping(address => Profile)  profilesMapping;
    Profile[] profiles; 

    function register(string memory _name) external {
        require(ens.getAddressFromName(_name) != address(0), "not a valid ENS");
        require(ens.getAddressFromName(_name) == _msgSender(), "ENS does not match your address");
        require(!isRegistered(_msgSender()), "You are already registered");
        Profile memory newProfile;
        newProfile.name = _name;
        newProfile.registered = true;

        profilesMapping[_msgSender()] = newProfile;
        profiles.push(newProfile);
    }

    function isRegistered(address _user) public view returns (bool){
        return profilesMapping[_user].registered;
    }

    function getProfile(address _user) external view returns(Profile memory){
        require(profilesMapping[_user].registered, "user not registered");
    
        Profile memory profile= profilesMapping[_user];

        return profile;
    }
    
    //start chat
    function sendMessage(
        string calldata _receiver,
        string calldata _message
    ) external {
        address receiver = ens.getAddressFromName(_receiver);

        require(isRegistered(_msgSender()), "You are not registered");
        require(isRegistered(receiver), "Receiver not registered");

        string memory sender = ens.getNameFromAddress(_msgSender());

        uint256 myChatId = chatsIds[_msgSender()][receiver];
        uint256 friendChatId = chatsIds[receiver][_msgSender()];

        if (myChatId == friendChatId && myChatId == 0) {
            chatId = chatId + 1;
            chatsIds[_msgSender()][receiver] = chatId;
            chatsIds[receiver][_msgSender()] = chatId;
            myChatId= chatId;
        }

        Message memory newMessage;
        newMessage.sender = sender;
        newMessage.receiver = _receiver
        newMessage.message = _message;
        newMessage.timestamp = block.timestamp;
        chats[myChatId].push(newMessage);

        emit MessageSent(_receiver, sender, _message);

        if (!conversationListMapping[_msgSender()][receiver]) {
            conversationList[_msgSender()].push(_receiver);
            conversationList[receiver].push(sender);

            conversationListMapping[_msgSender()][receiver] = true;
            conversationListMapping[receiver][_msgSender()] = true;
        }
    }

    //retrieve chats
    function getChats(
        string calldata _receiver
    ) external view returns (Message[] memory) {
        require(isRegistered(_msgSender()), "you are not registered");
        address receiver = ens.getAddressFromName(_receiver);
        uint256 myChatId = chatsIds[_msgSender()][receiver];
        Message[] memory chat = chats[myChatId];
        return chat;
    }

    function getConversationList() external view returns (string[] memory) {
        return conversationList[_msgSender()];
    }
}
