
var Test = require('../config/testConfig.js');
var BigNumber = require('../../node_modules/bignumber.js');

contract('ERC721Mintable', async (accounts) => {

    var config;

    before('setup contract', async () => {
        config = await Test.Config(accounts);

        console.log("-----------------------------")
        console.log("Owner         accounts[0]  : ", config.owner);
        console.log("account_one   accounts[0]  : ", config.account_one);
        console.log("account_two   accounts[1]  : ", config.account_two);
        console.log("name                       : ", config.name);
        console.log("symbol                     : ", config.symbol);
        console.log("baseTokenURI               : ", config.baseTokenURI);
        console.log("-----------------------------")
        console.log("ERC721Mintable Address     : ", config.myToken.address);
        console.log("-----------------------------")


    });

    describe('match erc721 spec', function () {

        /****************************************************************************************/
        /* ERC721Mintable Operations and Settings                                              */
        /****************************************************************************************/

        it(`1. should check correct  isOwner()`, async function () {

            // Get owner
            let status = await config.myToken.isOwner.call({ from: config.owner });
            assert.equal(status, true, "account[0] is owner");

        });

        it(`2. should return correct name()`, async function () {

            let status = await config.myToken.name.call();
            assert.equal(status, config.name, "name of myToken is  not  correct");

        });

        it(`3. should return correct symbol()`, async function () {

            let status = await config.myToken.symbol.call();
            assert.equal(status, config.symbol, "symbol of myToken is  not  correct");

        });

        it(`4. should return correct baseTokenURI()`, async function () {

            let status = await config.myToken.baseTokenURI.call();
            assert.equal(status, config.baseTokenURI, "baseTokenURI of myToken is  not  correct");

        });

        it(`5. should work pause/unpause `, async function () {

            config.myToken.Paused()
                .on('data', (event) => {
                    // console.log(`\n\nContract is paused: \n account : ${event.returnValues.account}`);
                })
                .on('error', console.error);

            config.myToken.Unpaused()
                .on('data', (event) => {
                    // console.log(`\n\nContract is unpaused: \n account : ${event.returnValues.account}`);
                })
                .on('error', console.error);
            // ARRANGE

            // ACT
            await config.myToken.pause({ from: config.owner });
            await config.myToken.unpause({ from: config.owner });

        });


        it('6. should mint 10 tokens', async function () {

            config.myToken.Transfer()
                .on('data', (event) => {
                    // console.log(`\n\n emit Transfer() tokenId : ${event.returnValues.tokenId}`);
                })
                .on('error', console.error);

            const tokenId = config.firstTokenId

            for (let i = tokenId; i <= config.lastTokenId; i++) {
                let status = await config.myToken.mint(config.owner, i, { from: config.owner });
            }

        })

        it('7. should return total supply', async function () {

            let status = await config.myToken.totalSupply.call();
            assert.equal(status, config.lastTokenId, "total supply is  not  correct");

        })

        it('8. should get token balance', async function () {

            let status = await config.myToken.balanceOf.call(config.owner);
            assert.equal(status, config.lastTokenId, "balanceOf  is  not  correct");
        })

        // token uri should be complete i.e: https://s3-us-west-2.amazonaws.com/udacity-blockchain/capstone/1
        it('9. should return token uri', async function () {

            const tokenId = config.firstTokenId
            let expectedTokenUri = config.baseTokenURI.concat(tokenId)
            //console.log(expectedTokenUri)

            let status = await config.myToken.tokenURI.call(tokenId, { from: config.owner });
            //console.log(status)
            assert.equal(status, expectedTokenUri, "token uri  is  not  complete");

        })

        it('10. should transfer token from one owner to another', async function () {
            const tokenId = config.firstTokenId
            // first approve
            let status1 = await config.myToken.approve(config.account_two, tokenId,
                { from: config.owner });
            // transfer 
            let status2 = await config.myToken.transferFrom(config.owner, config.account_two, tokenId,
                { from: config.owner });
            // check result
            let status3 = await config.myToken.ownerOf.call(tokenId);
            assert.equal(status3, config.account_two, "new owner of token  is  not  correct");
        })
    });

    describe('have ownership properties', function () {

        it('11. should return contract owner', async function () {
            // Get owner
            let status = await config.myToken.owner.call();
            assert.equal(status, config.owner, "account[0] is owner");
        })

        it('12. should fail when minting when address is not contract owner', async function () {

            const tokenId = config.lastTokenId + 1

            try {
                await config.myToken.mint(config.account_two, tokenId, { from: config.account_two });
            }
            catch (e) {
                console.log('\nMinting Error : ', e.reason);
            }
        })

    });

});
