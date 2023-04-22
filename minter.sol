// SPDX-License-Identifier: MIT
/*                                                                                                                      
        ,----,                                                                                                
      ,/   .`|                                                                                      ,----..    
    ,`   .'  :                                                          ,---,       ,---,          /   /   \   
  ;    ;     /                                                        .'  .' `\    '  .' \        /   .     :  
.'___,/    ,'                    ,--,  __  ,-.   ,---.              ,---.'     \  /  ;    '.     .   /   ;.  \ 
|    :     |                   ,'_ /|,' ,'/ /|  '   ,'\   .--.--.   |   |  .`\  |:  :       \   .   ;   /  ` ; 
;    |.';  ;  ,--.--.     .--. |  | :'  | |' | /   /   | /  /    '  :   : |  '  |:  |   /\   \  ;   |  ; \ ; | 
`----'  |  | /       \  ,'_ /| :  . ||  |   ,'.   ; ,. :|  :  /`./  |   ' '  ;  :|  :  ' ;.   : |   :  | ; | '      /*
    '   :  ;.--.  .-. | |  ' | |  . .'  :  /  '   | |: :|  :  ;_    '   | ;  .  ||  |  ;/  \   \.   |  ' ' ' : 
    |   |  ' \__\/: . . |  | ' |  | ||  | '   '   | .; : \  \    `. |   | :  |  ''  :  | \  \ ,''   ;  \; /  | 
    '   :  | ," .--.; | :  | : ;  ; |;  : |   |   :    |  `----.   \'   : | /  ; |  |  '  '--'   \   \  ',  /  
    ;   |.' /  /  ,.  | '  :  `--'   \  , ;    \   \  /  /  /`--'  /|   | '` ,/  |  :  :          ;   :    /   
    '---'  ;  :   .'   \:  ,      .-./---'      `----'  '--'.     / ;   :  .'    |  | ,'           \   \ .'    
           |  ,     .-./ `--`----'                        `--'---'  |   ,.'      `--''              `---`     
            `--`---'                                                '---'                                    
*/    
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract AppNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter public versions;
    mapping(uint256 => string) public builds;
    address public appOwner;

    constructor(string memory tokenURI) ERC721("AINFT", "AIAPP") {
        appOwner = msg.sender;
        mint(tokenURI);
    }

    function updateApp(string memory newTokenURI,uint256 _Id) public {
        require(
            msg.sender == appOwner,
            "Only the app owner can make this change"
        );
        uint256 currentVersion = versions.current();
        _setTokenURI(_Id, newTokenURI);
        builds[currentVersion + 1] = newTokenURI;
        versions.increment();
    }

    function getPreviousBuild(uint256 versionNumber)
        public
        view
        returns (string memory)
    {
        return builds[versionNumber];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not token owner nor approved"
        );

        _transfer(from, to, tokenId);
        appOwner = to;
    }

    function mint(string memory tokenURI) private returns (uint256) {
        require(msg.sender == appOwner, "Only TaurosDAO can list to Market ");
        versions.increment();
        uint256 tokenId = 1;
        uint256 currentVersion = versions.current();
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenURI);
        builds[currentVersion] = tokenURI;
        return tokenId;
    }
    function mintNew(string memory tokenURI,uint256 _Id) public returns (uint256) {
        require(msg.sender == appOwner, "Only TaurosDAO can list to Market ");
        versions.increment();
        uint256 tokenId = _Id;
        uint256 currentVersion = versions.current();
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenURI);
        builds[currentVersion] = tokenURI;
        return tokenId;
    }
}
