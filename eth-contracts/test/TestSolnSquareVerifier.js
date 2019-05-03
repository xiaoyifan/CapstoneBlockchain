// Test if a new solution can be added for contract - SolnSquareVerifier
// Test if an ERC721 token can be minted for contract - SolnSquareVerifier

var Test = require('../config/testConfig.js');

contract('SolnSquareVerifier', async (accounts) => {

    var config;
    var proof;
    var input;

    before('setup contract', async () => {
        config = await Test.Config(accounts);
        proof = config.proof;
        input = config.input;

        console.log("-----------------------------")
        console.log("Owner         accounts[0]  : ", config.owner);
        console.log("account_one   accounts[0]  : ", config.account_one);
        console.log("account_two   accounts[1]  : ", config.account_two);
        console.log("name                       : ", config.name);
        console.log("symbol                     : ", config.symbol);
        console.log("baseTokenURI               : ", config.baseTokenURI);
        console.log("-----------------------------")
        console.log("SolnSquareVerifier Address : ", config.solnSquareVerifier.address);
        console.log("-----------------------------")


    });

    describe('match erc721 spec', function () {

        /****************************************************************************************/
        /* ERC721Mintable Operations and Settings                                              */
        /****************************************************************************************/

        it(`1. should check correct  isOwner()`, async function () {

            // Get owner
            let status = await config.solnSquareVerifier.isOwner.call({ from: config.owner });
            assert.equal(status, true, "account[0] is owner");

        });

        it(`2. should return correct name()`, async function () {

            let status = await config.solnSquareVerifier.name.call();
            assert.equal(status, config.name, "name of myToken is  not  correct");

        });

        it(`3. should return correct symbol()`, async function () {

            let status = await config.solnSquareVerifier.symbol.call();
            assert.equal(status, config.symbol, "symbol of myToken is  not  correct");

        });

        it(`4. should return correct baseTokenURI()`, async function () {

            let status = await config.solnSquareVerifier.baseTokenURI.call();
            assert.equal(status, config.baseTokenURI, "baseTokenURI of myToken is  not  correct");

        });

        it('5. should return contract owner', async function () {
            // Get owner
            let status = await config.solnSquareVerifier.owner.call();
            assert.equal(status, config.owner, "account[0] is owner");
        })

        it('6. should mint an ERC721 token ', async function () {

            config.solnSquareVerifier.Transfer()
                .on('data', (event) => {
                    console.log(`\n\n emit Transfer() tokenId : ${event.returnValues.tokenId}`);
                })
                .on('error', console.error);

            const tokenId = config.firstTokenId

            let status = await config.solnSquareVerifier.mint(
                config.owner,
                tokenId, { from: config.owner });

        })

        it('7. should return total supply', async function () {

            let status = await config.solnSquareVerifier.totalSupply.call();
            assert.equal(status, 1, "total supply is  not  correct");

        })

        it('8. should add a  new solutions', async function () {

            config.solnSquareVerifier.Transfer()
                .on('data', (event) => {
                    console.log(`\n\n emit Transfer() tokenId : ${event.returnValues.tokenId}`);
                })
                .on('error', console.error);

            const tokenId = config.firstTokenId + 1

            let status = await config.solnSquareVerifier.addSolution(
                proof.A,
                proof.A_p,
                proof.B,
                proof.B_p,
                proof.C,
                proof.C_p,
                proof.H,
                proof.K,
                input,
                config.owner,
                tokenId, {
                    from: config.owner
                });

        })

    });

});
