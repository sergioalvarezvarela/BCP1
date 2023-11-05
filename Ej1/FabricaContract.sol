// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0;

contract FabricaContract {
    uint idDigits = 16;

    struct Producto{
        string nombre;
        uint identificacion;
    }

    Producto[] public productos;

    mapping (uint => address) public productoAPropietario;
    mapping (address => uint) propietarioProductos;

    event NuevoProducto(uint _arrayProductoId, string _nombre, uint _id);

    function _crearProducto(string memory _nombre, uint _id) private {
        productos.push(Producto(_nombre, _id));
        emit NuevoProducto(productos.length - 1, _nombre, _id);
    }

    function _generarIdAleatorio(string memory _str) view private returns(uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        uint idModulus = 10 ^ idDigits;
        return rand % idModulus;
    }

    function crearProductoAleatorio(string memory _nombre) public {
        uint randId = _generarIdAleatorio(_nombre);
        _crearProducto(_nombre, randId);
    }

    // Preguntar sobre esta función
    function Propiedad (uint _id) public {
        productoAPropietario[_id] = msg.sender;
        propietarioProductos[msg.sender]++;
    }

    function getProductosPorPropietario(address _propietario) external view returns (uint[] memory) {
        uint contador = 0;
        uint[] memory resultado = new uint[](propietarioProductos[_propietario]);

        for (uint i = 0; i < productos.length; i++) {
            if (productoAPropietario[i] == _propietario) {
                resultado[contador] = i;
                contador++;
            }
        }

        return resultado;
    }
}
