// This file is MIT Licensed.
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

pragma solidity >=0.4.21 <0.6.0;

library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    /// @return the generator of G1
    function P1() pure internal returns (G1Point memory) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() pure internal returns (G2Point memory) {
        return G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );
    }
    /// @return the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point memory p) pure internal returns (G1Point memory) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return the sum of two points of G1
    function addition(G1Point memory p1, G1Point memory  p2) internal returns (G1Point memory  r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 6, 0, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
    }
    /// @return the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point memory  p, uint s) internal returns (G1Point memory  r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 7, 0, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require (success);
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory  p1, G2Point[] memory  p2) internal returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }
        uint[1] memory out;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 8, 0, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point memory  a1, G2Point memory  a2, G1Point memory  b1, G2Point memory  b2) internal returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
            G1Point memory  a1, G2Point memory  a2,
            G1Point memory  b1, G2Point memory  b2,
            G1Point memory  c1, G2Point memory  c2
    ) internal returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
            G1Point memory  a1, G2Point memory  a2,
            G1Point memory  b1, G2Point memory  b2,
            G1Point memory  c1, G2Point memory  c2,
            G1Point memory  d1, G2Point memory  d2
    ) internal returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}
contract Verifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G2Point A;
        Pairing.G1Point B;
        Pairing.G2Point C;
        Pairing.G2Point gamma;
        Pairing.G1Point gammaBeta1;
        Pairing.G2Point gammaBeta2;
        Pairing.G2Point Z;
        Pairing.G1Point[] IC;
    }
    struct Proof {
        Pairing.G1Point A;
        Pairing.G1Point A_p;
        Pairing.G2Point B;
        Pairing.G1Point B_p;
        Pairing.G1Point C;
        Pairing.G1Point C_p;
        Pairing.G1Point K;
        Pairing.G1Point H;
    }
    function verifyingKey() pure internal returns (VerifyingKey  memory vk) {
        vk.A = Pairing.G2Point([0xca61a93841aa4197454b498513b11da5bc719891326ef5a220a8651a908abdc, 0x256c13b043c2649efcdcc659c1a64af3bbc32b758c257816747363a0fd8319be], [0x69c3e2431c6f87498062421834a5311e39c523f9ff9e26d9ae2e22adf8862a8, 0x21ac2996bfb507198e932ef3a229dfda719ebb84913dd1172a5f5a9a9b1fbc46]);
        vk.B = Pairing.G1Point(0x2813f7f75fb8198b89aa5580a4af63fc575fee53ba85100a1fb59f8dcd1a2913, 0x29d903aecab03b41ec896d601a6078df39bdd9a6450c2db4962ff0ce32adbe8f);
        vk.C = Pairing.G2Point([0xd97d2b5cd886f3dad2d526ff5705e7a3824b42b3c9a81306351203f75b90f3f, 0x1895ae4559e881fc5a44348776cb2bac67c2bcda0c8b1dda6b587479797aea57], [0x27e9842ce03eb7e97eaa4610f1767cab535eedd32c348a97f0d3454f127cf204, 0x7a3f979fc1224b14ee139e0f0758e483ee7a108f644e6796f0e8627f8b1a4f0]);
        vk.gamma = Pairing.G2Point([0x104cbde2d208dd0db1f2ccbed8173a66ba6a40025af0001ce96aa8fe8618ce32, 0x28e20ebaeb0a8a447c3a7d523e4bbd8374ed83fa7d9e2f03e7e6eaced767346c], [0x11f0667e7e37681ff663098b8c563e8a48f5c71a101055ddcd2ca3f29f71bbfb, 0x26d76e3f718cd7f764858a4b1e5b62d1fe5638c6cb19f7c8c0a8219e088ee4ba]);
        vk.gammaBeta1 = Pairing.G1Point(0x206a8402b63e671bff42af8fcea70307d5209d1827afdb99c70a5245fc9c0f4b, 0x11c19af66243440fdad4607a884e25420bf987260823d1ffbe88fc807b2485f9);
        vk.gammaBeta2 = Pairing.G2Point([0x57cf15ea5f597eb801c5f9d6a5c9983c3fd146dbd7240414229c7ea38038959, 0x2e7a9a7492d0fdb8b2dcc539a046814d49554614adee024241f4f40c9d665c53], [0x2b38e30fad9c7ec42aed499e5c6e7dbc998634a3c145488eb692758d73888e79, 0xe51e2e91fe5497a83b2735b67f8ae46bbe1bdc00ae3bef15108dac8bb83eae7]);
        vk.Z = Pairing.G2Point([0x2ed8da4e57d701410f7ab8f58e5f3321a40f87fbeed3fa344779123abda20245, 0x248a6549f0c45eaae23ee900a160d2aaf8176aa038e6759fd6728b401b4450b4], [0x2565e6ad3da4abca8faf500f71709db84df2608abed2ad71843fc8a62c397b38, 0x1eca0ed750cdf7950228371a261c161de9b9bbf9df6ec02352ac0d9ea7560adc]);
        vk.IC = new Pairing.G1Point[](3);
        vk.IC[0] = Pairing.G1Point(0x1701849fe2e0bdd4a7cef0ebb6a586f57830f607ba7c3b768adcf10016d2dd5c, 0xb38df216001a385c2b1df33d608458938a50e3193315f61d940f79d0932106a);
        vk.IC[1] = Pairing.G1Point(0x427363bcb2167b1cfdfb2ce1da57cca5205cd31ee43407e8f2fcf42dd883f16, 0x68ec9437b12312e3d371443af1e72fbdd5874d9e27eab3e1b025e60c505c8ff);
        vk.IC[2] = Pairing.G1Point(0x2c108923dc54c83b0b82e647a7560c5284dc8149a3b088ec16db427af2a40b20, 0x2a3d184ce576df15d995fbc7c92c91f3163cf213243fbc81bdcb8eafaa38eab7);
    }
    function verify(uint[] memory  input, Proof memory  proof) internal returns (uint) {
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.IC.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++)
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
        vk_x = Pairing.addition(vk_x, vk.IC[0]);
        if (!Pairing.pairingProd2(proof.A, vk.A, Pairing.negate(proof.A_p), Pairing.P2())) return 1;
        if (!Pairing.pairingProd2(vk.B, proof.B, Pairing.negate(proof.B_p), Pairing.P2())) return 2;
        if (!Pairing.pairingProd2(proof.C, vk.C, Pairing.negate(proof.C_p), Pairing.P2())) return 3;
        if (!Pairing.pairingProd3(
            proof.K, vk.gamma,
            Pairing.negate(Pairing.addition(vk_x, Pairing.addition(proof.A, proof.C))), vk.gammaBeta2,
            Pairing.negate(vk.gammaBeta1), proof.B
        )) return 4;
        if (!Pairing.pairingProd3(
                Pairing.addition(vk_x, proof.A), proof.B,
                Pairing.negate(proof.H), vk.Z,
                Pairing.negate(proof.C), Pairing.P2()
        )) return 5;
        return 0;
    }
    event Verified(string s);
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
        ) public returns (bool r) {
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.A_p = Pairing.G1Point(a_p[0], a_p[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.B_p = Pairing.G1Point(b_p[0], b_p[1]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        proof.C_p = Pairing.G1Point(c_p[0], c_p[1]);
        proof.H = Pairing.G1Point(h[0], h[1]);
        proof.K = Pairing.G1Point(k[0], k[1]);
        uint[] memory inputValues = new uint[](input.length);
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            emit Verified("Transaction successfully verified.");
            return true;
        } else {
            return false;
        }
    }
}