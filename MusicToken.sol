pragma solidity ^0.4.26;

contract MusicToken {
    uint public INITIAL_SUPPLY;     // 발행 토큰 개수
    string public name = 'MST';     // 토큰이름
    address owner;                  // 배포자 주소
    bool public released = false;   // 음원 등록 여부
    
    // 해당 주소의 보유 토큰 개수
    mapping (address => uint256) public balanceOf;  
    
    // 음원 구조체
    struct Song{            
        bool registered;    // 음원 등록여부
        bytes32 ID;         // 아이디
        string name;        // 음원 이름 
        string author;      // 음원 저작권자 
    }
    
    mapping(bytes32 => Song) songInfo;  // 음원 정보
    
    // 생성자
    constructor(uint numOfToken) public{   
        require(numOfToken != 0);         
        INITIAL_SUPPLY = numOfToken;                // 발행 토큰 개수 설정
        balanceOf[msg.sender] = INITIAL_SUPPLY;     // 배포자에게 모든 토큰 부여
        owner = msg.sender;                         // 배포자 주소 저장
    }

    // 토큰 전송 이벤트 로그 
    event Transfer(address _from, address _to, uint _value);   
    event _ID(bytes32 _id);

    // 음원 등록 여부 함수변경자
    modifier onlyReleased(){    
        require(released);
        _;
    }

    // 발행 토큰 개수 출력
    function get() public view returns (uint){      
        return INITIAL_SUPPLY;
    }

    // 음원 등록
    function register(string songName, string authorName) public returns(bytes32) {     
        string memory empty = "";
        
        require((keccak256(bytes(songName)) == keccak256(bytes(empty))) == false);        // 반드시 음원 이름 입력
        require((keccak256(bytes(authorName)) == keccak256(bytes(empty))) == false);      // 반드시 음원 저작권자 입력
        require(owner == msg.sender);   // 토큰의 발행자만 토큰을 출시할 수 있도록함
        require(!released);             // 음원이 등록 안되어 있을 경우에만 실행
         
        released = true;                // 음원 등록 설정

        bytes32 songID = keccak256(songName, authorName);       // 음원 이름과 저작권자의 해시값으로 음원 아이디 생성
        songInfo[songID].ID = songID;
        songInfo[songID].registered = true;
        songInfo[songID].name = songName;
        songInfo[songID].author = authorName;

        emit _ID(songID);
        return songID;
    }
    
    
    // 음원 아이디에 대한 등록 여부 출력
    function checkSongExists(bytes32 songID) onlyReleased public constant returns (bool) {
        return songInfo[songID].registered;
    }
  
    // 음원 아이디에 대한 이름 출력
    function getSongName(bytes32 songID) onlyReleased public constant returns (string){
      Song storage song = songInfo[songID];
      return song.name; 
    }
    
    // 음원 아이디에 대한 저작권자 출력
    function getSongAuthor(bytes32 songID) onlyReleased public constant returns (string){
      Song storage song = songInfo[songID];
      return song.author; 
    }
  
    // 토큰 전송 함수
    function transfer(address _to, uint256 _value) public {
         require(_value <= balanceOf[msg.sender]);
         require(balanceOf[_to] + _value >= balanceOf[_to]);
         balanceOf[msg.sender] -= _value;
         balanceOf[_to] += _value;
         emit Transfer(msg.sender, _to, _value);
    }

    // 토큰 전송 함수  
    function transferFrom(address _from, address _to, uint256 _value) public {
         require(_value <= balanceOf[_from]);
         require(balanceOf[_to] + _value >= balanceOf[_to]);
         balanceOf[_from] -= _value;
         balanceOf[_to] += _value;
         emit Transfer(_from, _to, _value);
    }

}