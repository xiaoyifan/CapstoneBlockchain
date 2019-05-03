pragma solidity >=0.4.21 <0.6.0;
import './ERC721Mintable.sol';

// TODO define a contract call to the zokrates generated solidity contract <Verifier> or <renamedVerifier>
// TODO define another contract named SolnSquareVerifier that inherits from your ERC721Mintable class
// TODO define a solutions struct that can hold an index & an address
// TODO define an array of the above struct
// TODO define a mapping to store unique solutions submitted
// TODO Create an event to emit when a solution is added
// TODO Create a function to add the solutions to the array and emit the event
// TODO Create a function to mint new NFT only after the solution has been verified
//  - make sure the solution is unique (has not been used before)
//  - make sure you handle metadata as well as tokenSuplly

contract SolnSquareVerifier is ERC721Mintable {

    Verifier verifierContract;
    
    struct Solution {
        uint[2]  a;
        uint[2]  a_p;
        uint[2][2]  b;
        uint[2]  b_p;
        uint[2]  c;
        uint[2]  c_p;
        uint[2]  h;
        uint[2]  k;
        uint[2]  input;
        address to;
        uint256 tokenId;
    }

    mapping(bytes32 => Solution) solutions;
    mapping(bytes32 => bool) solutionsExist;

    event SolutionAdded(address owner);

    constructor(address verifierAddress, string memory name, string memory symbol, string memory baseTokenURI )
        ERC721Mintable(name, symbol, baseTokenURI) public 
    {
        verifierContract = Verifier(verifierAddress);
    }

    function addSolution(
            uint[2] memory a,
            uint[2] memory a_p,
            uint[2][2] memory b,
            uint[2] memory b_p,
            uint[2] memory c,
            uint[2] memory c_p,
            uint[2] memory h,
            uint[2] memory k,
            uint[2] memory input,
            address to,
            uint256 tokenId) 
            public returns (bool)
    {
        Solution memory Sol = Solution( a, a_p, b, b_p, c, c_p, h, k, input,to,tokenId );
        bytes32 key = keccak256(abi.encodePacked(a,a_p,b,b_p,c,c_p,h,k,input,to,tokenId));
        solutions[key] = Sol;

        emit SolutionAdded(msg.sender);
        bool check = mintVerified(key,to,tokenId);
        return check;
    }

    function mintVerified( bytes32 key, address to, uint256 tokenId) public returns (bool) 
    {
        bool Completed = false;
        bool check = solutionsExist[key]; /// checking if the solution is unique or not
      
        Solution memory sol = solutions[key];
        if(check != true)
        {
          bool verification = verifierContract.verifyTx(sol.a,sol.a_p,sol.b,sol.b_p,sol.c,sol.c_p,sol.h,sol.k,sol.input);
          if(verification == true)
          { 
            solutionsExist[key] = true;
            super.mint(to,tokenId);
            Completed = true;
            } 
        }
        return Completed;
    }
}
contract Verifier {

    function verifyTx(
            uint[2] memory  a,
            uint[2] memory  a_p,
            uint[2][2] memory  b,
            uint[2] memory  b_p,
            uint[2] memory  c,
            uint[2] memory  c_p,
            uint[2] memory  h,
            uint[2] memory  k,
            uint[2] memory  input
        ) 
        public returns (bool r);

}

