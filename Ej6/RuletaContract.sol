// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract LaRuleta is Ownable {

    enum Paridad{ PAR, IMPAR, NONE }
    enum Color{ ROJO, NEGRO, VERDE }
    enum Docena{ PRIM, SEGUN, TERC, NONE }

	struct Numero {
  	    uint8 numero;
        Paridad paridad;
        Color color;
        Docena docena;
    }

    struct Apuesta {
        address payable jugador;
        Numero numero;
        uint cantidad;
    }
  
    Numero[] public ruleta;
    uint randNonce;

    event PremioEntregado(address jugador, uint premio);
    event DepositoRealizado(address owner, uint256 monto);
    event RetiroRealizado(address owner, uint256 monto);

	constructor() Ownable(msg.sender) {
        randNonce = 0;
        ruleta.push(Numero(0, Paridad.NONE, Color.VERDE, Docena.NONE));

        for (uint8 i = 1; i < 37; i++){
            uint8 numero = i;
            uint8 suma = 0;
            Color color;
            Paridad paridad;
            Docena docena;

            if (i == 10 || i == 28 ) {
                color = Color.NEGRO;
            } else {
                while (numero > 0) {
                suma += numero % 10;
                numero /= 10;
                }
                if (suma % 2 == 0) {
                    color = Color.NEGRO;
                } else {
                    color = Color.ROJO;
                }
            }
            
            if (i % 2 == 0) {
                paridad = Paridad.PAR;
            } else {
                paridad = Paridad.IMPAR;
            }

            if (i <= 12) {
                docena = Docena.PRIM;
            } else if (i >= 25) {
                docena = Docena.TERC;
            } else {
                docena = Docena.SEGUN;
            }
        
            ruleta.push(Numero(i, paridad, color, docena));
        
        }

        ruleta.push(Numero(37, Paridad.NONE, Color.VERDE, Docena.NONE));
    }

    function _girarRuleta() private returns (Numero memory) {

        uint random = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % 38;
        randNonce++;

        return ruleta[random];
    }

    function _revisarTipoApuesta(Apuesta memory _apuesta, Numero memory _numero_ganador) private pure returns (uint) {
        Numero memory numero_apostado = _apuesta.numero;

        if (numero_apostado.numero != 38) {
            if (numero_apostado.numero == _numero_ganador.numero) {
                return _apuesta.cantidad * 36;
            }
        } else if (numero_apostado.color != Color.VERDE) {
            if (numero_apostado.color == _numero_ganador.color) {
                return _apuesta.cantidad * 2;
            } 
        } else if (numero_apostado.paridad != Paridad.NONE) {
            if (numero_apostado.paridad == _numero_ganador.paridad) {
                return _apuesta.cantidad * 2;
            } 
        } else if (numero_apostado.docena != Docena.NONE) {
            if (numero_apostado.docena == _numero_ganador.docena) {
                return _apuesta.cantidad * 3;
            }
        } 
        return 0;
    }

    function _hacerApuesta(Numero memory _numero, address payable jugador, uint cantidad) private returns (uint) {
        require(cantidad > 0, "You must provide some ETH");

        return _revisarTipoApuesta(Apuesta(payable(jugador), _numero, cantidad), _girarRuleta());
    }

    function hacerApuestaNumero(uint8 _numero) public payable {
        require(_numero >= 0 && _numero <= 37, "Invalid number");

        uint premio = _hacerApuesta(Numero(_numero, Paridad.NONE, Color.VERDE, Docena.NONE), payable (msg.sender), msg.value);

        if (premio > 0) {
            payable(msg.sender).transfer(premio);
            emit PremioEntregado(payable(msg.sender), premio);
        }
    }

    function hacerApuestaColor(uint8 _color) public payable {
        require(_color >= 0 && _color <= 1, "Invalid number");

        Color apuestaColor;

        if (_color == 0) {
            apuestaColor = Color.ROJO;
        } else {
            apuestaColor = Color.NEGRO;
        }

        uint premio = _hacerApuesta(Numero(38, Paridad.NONE, apuestaColor, Docena.NONE), payable (msg.sender), msg.value);

        if (premio > 0) {
            payable(msg.sender).transfer(premio);
            emit PremioEntregado(payable(msg.sender), premio);
        }
    }

    function hacerApuestaParidad(uint8 _paridad) public payable {
        require(_paridad >= 0 && _paridad <= 1, "Invalid number");

        Paridad apuestaParidad;

        if (_paridad == 0) {
            apuestaParidad = Paridad.PAR;
        } else {
            apuestaParidad = Paridad.IMPAR;
        }

        uint premio = _hacerApuesta(Numero(38, apuestaParidad, Color.VERDE, Docena.NONE), payable (msg.sender), msg.value);

        if (premio > 0) {
            payable(msg.sender).transfer(premio);
            emit PremioEntregado(payable(msg.sender), premio);
        }
    }

    function hacerApuestaDocena(uint8 _docena) public payable {
        require(_docena >= 0 && _docena <= 2, "Invalid number");

        Docena apuestaDocena;

        if (_docena == 0) {
            apuestaDocena = Docena.PRIM;
        } else if (_docena == 1) {
            apuestaDocena = Docena.SEGUN;
        } else {
            apuestaDocena = Docena.TERC;
        }

        uint premio = _hacerApuesta(Numero(38, Paridad.NONE, Color.VERDE, apuestaDocena), payable (msg.sender), msg.value);

        if (premio > 0) {
            payable(msg.sender).transfer(premio);
            emit PremioEntregado(payable(msg.sender), premio);
        }
    }

    // Only Owner functions

    function cargarRuleta() public payable onlyOwner {
        require(msg.value > 0, "You must provide some ETH");

        emit DepositoRealizado(owner(), msg.value);
    }

    function verSaldoRuleta() public view onlyOwner returns (uint256) {
        return address(this).balance;
    }

    function retirarSaldoRuleta(uint256 monto) public payable onlyOwner {
        require(monto > 0, "You must indicate a valid amount of ETH");
        require(address(this).balance >= monto, "Not enough ETH");

        payable(owner()).transfer(monto);

        emit RetiroRealizado(owner(), monto);
    }
}