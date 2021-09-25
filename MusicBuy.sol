//토큰 판매를 위한 계약 작성
pragma solidity ^0.4.24;
import './MusicToken.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract MusicBuy{
    using SafeMath for uint256;                         // SafeMath 사용
    uint public constant TOKEN_PER_ETH = 1 ether;       // 토큰 개수 당 ETH 비율
    uint public constant TOEKN_PER_FIN = 100 finney;    // 토큰 개수 당 FIN 비율
    uint public numberOfToken;                          // 발행 토큰 개수
    uint public saledToken;                             // 판매된 전체 토큰 수
    address owner;                                      // 배포자 주소
    MusicToken public token;                            // 토큰 인터페이스
    
    // 투자자 구조체
    struct licenseHolder{   
        address holder;             // 투자자 주소
        uint256 totaltoken;         // 투자자 보유 토큰 수
    }
    
    // 투자자 리스트
    licenseHolder[] public licenseHolders;


    // 생성자
    function MusicBuy (MusicToken _token) public {
        require(_token != address(0));
        token = _token;
        owner = msg.sender;
        numberOfToken = token.get();
    } 

    
    function () external payable { 
        require(msg.value != 0);

        // 투자자일 경우, 음원 구매
        if (msg.sender != owner){

            uint wantToken = msg.value.div(TOKEN_PER_ETH);
            uint refund = 0;
            
            // 판매 할 토큰 수 보다 더 많은 토큰을 요구할 경우
            // 판매 가능한 토큰만 판매 후 나머지 금액 환불
            if (saledToken.add(wantToken) > numberOfToken){
                wantToken = numberOfToken.sub(saledToken);
                refund = msg.value.sub(( wantToken.mul(TOKEN_PER_ETH)));
            }
            
            // 판매된 전체 토큰 수 update
            saledToken = saledToken.add(wantToken);
            
            // 환불할 금액이 있다면 환불
            if(refund > 0){
                msg.sender.transfer(refund);
                owner.transfer(wantToken.mul(TOKEN_PER_ETH));
            }else{
                owner.transfer(msg.value);       
            }
            
            // 토큰 전송
            token.transferFrom(owner, msg.sender, wantToken);
            
            // 투자자 등록
            licenseHolders.push(licenseHolder(msg.sender,wantToken));
        }

        // 배포자일 경우, 수익 분배
        else{
            uint balan = msg.value;
            
            // 리스트에 있는 모든 투자자에게 수익 분배
            for(uint i=0; i< licenseHolders.length; i++){
                address holderAddress = licenseHolders[i].holder;
                uint holderToken = licenseHolders[i].totaltoken;

                holderAddress.transfer(holderToken.mul(TOEKN_PER_FIN));
                balan = balan.sub(holderToken.mul(TOEKN_PER_FIN));
            }
            
            msg.sender.transfer(balan);

        }
    }
}
