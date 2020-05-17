pragma solidity ^0.6.0;
import "./EnumerableSet.sol";
abstract contract InterOftoken{
    string public readme;
    string public type_;
    function getlength(address owner)public view virtual returns(uint256 len_);
    function getIndexByIndex(address owner,uint256 index)public view virtual returns(uint256 A_asset);
    function ownerOf(uint256 tokenId) public view virtual  returns (address);
}
contract Asset{
    using EnumerableSet for EnumerableSet.AddressSet;
    struct link{
        bool useful;
        string readme;
        mapping(address=>uint256[]) data;//index
        mapping(address=>mapping(uint256=>uint256)) index;
        mapping(address=>bool) isexsit;
        address[] type_add;
    }
    //
    mapping(address=>mapping(string=>EnumerableSet.AddressSet)) private assets;
    mapping(address=>link[]) private linkbtwtokens;
    mapping(address=>uint256) public linkbtwtokens_len;
    //mapping(address=>string) private assetss;
    string[] public link_show;//给出来的模板
    string[] public link_readme;//解释
    
    mapping(string=>uint256) public types;
    uint256 public len_types=1;
	/******************
	*state相关，即设置或者获取state，用于收录资产相关的地址。
	*
	*******************/
    function setstate(address add)public returns(bool){
       string memory type_ = InterOftoken(msg.sender).type_();
       if(types[type_] == 0){
            types[type_] = len_types;
            len_types++;
       }
        
       if(getstate(add,msg.sender)==false)
       assets[add][InterOftoken(msg.sender).type_()].add(msg.sender);
    }
    function getstate(address add)public view returns(bool){
        if(assets[add][InterOftoken(msg.sender).type_()].contains(msg.sender)==false)
        return false;
        return true;
    }
    function getstate(address add,address _msgSender)public view returns(bool){
        if(assets[add][InterOftoken(_msgSender).type_()].contains(msg.sender)==false)
        return false;
        return true;
    }
    function getasset(address add,string memory type_0)public view returns(address[] memory addset){
        EnumerableSet.AddressSet storage asset_ = assets[add][type_0];
        uint256 len_ = asset_.length_0();//only valiable for storage
        addset = new address[](len_);
        for(uint i=0;i<len_;i++){
            addset[i] = asset_.at(i);//not allowed push in view function
        }
        
    }
    function getassetandRemove(address add,string memory type_0)public  returns(address[] memory addset){
        EnumerableSet.AddressSet storage asset_ = assets[add][type_0];
        uint256 len_ = asset_.length_0();//only valiable for storage
        addset = new address[](len_);
        for(uint i=0;i<len_;i++){
            addset[i] = asset_.at(i);//not allowed push in view function
            if(InterOftoken(addset[i]).getlength(add) == 0)
              asset_.remove(addset[i]);
        }
        
    }
	/******************
	*用于管理资产之间的联系，比如是否在在同一个网页显示等等
	*
	*******************/
    //对于单向/双向链接，应该在readme中说明
	/**
	*@dev 用于创建新联系
	*@readme_ 解析文档
	*/
    function newlink(string memory readme_)
    public
    returns(uint256){
        linkbtwtokens[msg.sender][linkbtwtokens_len[msg.sender]].readme = readme_;
        linkbtwtokens[msg.sender][linkbtwtokens_len[msg.sender]].useful = true;
        linkbtwtokens_len[msg.sender] ++;
        return linkbtwtokens_len[msg.sender]-1;
       
    }//readme equal null 表示双向显示或者其他
	/**
	*@dev 用于创建新联系
	*@index_ 联系索引
	*/
    function changeuseful(uint256 index_)
    public
    {
        require(linkbtwtokens_len[msg.sender]>index_,"out of range");
        linkbtwtokens[msg.sender][index_].useful = !(linkbtwtokens[msg.sender][index_].useful);
    }
	/**
	*@dev 用于创建新联系
	*@readme_ 解析文档
	*@index_ 联系索引
	*/
    function changelink(string memory readme_,uint256 index_)
    public 
    {
        require(linkbtwtokens_len[msg.sender]>index_,"out of range");
        require(linkbtwtokens[msg.sender][index_].useful,"not use");
        linkbtwtokens[msg.sender][index_].readme = readme_;
    }
	/**
	*@dev 用于创建新联系
	*@index_ 联系索引
	*@add_ 资产地址
	*@indexes 一系列用户内部（Set）中的索引
	*/
    function addlinkMess(uint256 index_,address add_,uint256[] memory indexes)//这里indexs指在资产该用户内部的排序
    public
    {
        require(linkbtwtokens_len[msg.sender]>index_,"out of range");
        require(linkbtwtokens[msg.sender][index_].useful,"not use");
        link storage link_ = linkbtwtokens[msg.sender][index_];
        if(!(link_.isexsit[add_]))
          link_.type_add.push(add_);
        for(uint i=0;i<indexes.length;i++)
        {
            uint256 indexOfToken = InterOftoken(add_).getIndexByIndex(msg.sender,indexes[i]);
            require(InterOftoken(add_).ownerOf(indexOfToken)==msg.sender,"not belong you");
            link_.data[add_].push(indexOfToken);
            link_.index[add_][indexOfToken] = i+1;//plus 1 not 0,0 means not exsit;
        }
    }
	/**
	*@dev 用于创建新联系
	*@index_0 联系索引
	*@add_ 资产地址
	*@indexOfToken token索引
	*/
    function removelinkMess(uint256 index_0,address add_,uint256 indexOfToken)
    public
    {
        require(linkbtwtokens_len[msg.sender]>index_0,"out of range");
        require(linkbtwtokens[msg.sender][index_0].useful,"not use");
        link storage link_ = linkbtwtokens[msg.sender][index_0];
        uint256 index_ = link_.index[add_][indexOfToken];
        require(index_>0,"not exsit");
        uint256 len_ = link_.data[add_].length;
        if(index_ == len_)
          link_.data[add_].pop();
        else{
          uint256 theLast = link_.data[add_][len_-1];
          link_.data[add_][index_-1] = theLast;
          link_.index[add_][theLast] = index_;
          link_.data[add_].pop();
        }
    }
	/******************
	*用于获取资产之间的联系
	*
	*******************/
    function getreadme(address add,uint256 index_)public view returns(string memory readme_){
        require(linkbtwtokens_len[add]>index_,"out of range");
        require(linkbtwtokens[add][index_].useful,"not use");
        return linkbtwtokens[add][index_].readme;
    }
    function getaddress(address add,uint256 index_)public view returns(address[] memory addset){
        require(linkbtwtokens_len[add]>index_,"out of range");
        require(linkbtwtokens[add][index_].useful,"not use");
        link storage link_ = linkbtwtokens[add][index_];
        uint256 len_ = link_.type_add.length;
        addset = new address[](len_);
        for(uint i=0;i<len_;i++){
            addset[i] = link_.type_add[i];
        }
    }
	/**
	*@dev 用于获取联系中的数据
	*@add 用户地址
	*@index_ 联系索引
	*@add_indexed 资产地址
	*/
    function getdataByaddress(address add,uint256 index_,address add_indexed)
    public 
    view 
    returns(uint256[] memory indexes){
        require(linkbtwtokens_len[add]>index_,"out of range");
        require(linkbtwtokens[add][index_].useful,"not use");
        link storage link_ = linkbtwtokens[add][index_];
        require(link_.isexsit[add_indexed],"not exsit");
        uint256 len_ = link_.data[add_indexed].length;
        indexes = new uint256[](len_);
        for(uint i=0;i<len_;i++){
            uint256 index_of_token = link_.data[add_indexed][i];
            if(InterOftoken(add_indexed).ownerOf(index_of_token)==add)
            indexes[i] = index_of_token;
            else
            indexes[i] = 0;
        }
    }
	/**
	*@dev 用于获取联系中的数据
	*@add 用户地址
	*@indexOfToken token索引
	*@add_indexed 资产地址
	*/
    function getIndexByindexOfToken(address add,uint256 indexOfToken,address add_indexed)
    public
    view
    returns(uint256 index)
    {
        for(uint i=0;i<linkbtwtokens_len[add];i++){
            if(!(linkbtwtokens[add][i].useful))
            continue;
            if(linkbtwtokens[add][i].index[add_indexed][indexOfToken]!=0)
              {
                  index = i;
                  break;
              }
              
        }
    }
}