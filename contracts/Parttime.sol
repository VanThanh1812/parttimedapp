pragma solidity ^0.4.17;

contract PartTime {
  
  struct Job {
    uint256 id;
    address creator;
    uint256 salary;
    uint256 start;
    uint256 end;
    uint256 timeOut;
    string title;
    string image;
    string description;
  }

  event NewJob(
    uint256 indexed id,
    address creator,
    uint256 salary,
    uint256 timeOut
  );

  event TakeJob(
    uint256 indexed id,
    address indexed labor
  );
  
  uint256 constant public MINIUM_SALARY = 0.1 ether;
  
  uint256 totalJob;

  mapping (uint256 => Job) public jobData;

  modifier onlyHaveFund{
    require(msg.value > MINIUM_SALARY);
    _;
  }
  
  modifier onlyValidTimeOut(uint256 timeOut){
      require(timeOut > 3 days);
      _;
  }
  
  modifier onlyValidId(uint256 jobId){
      require(jobId < totalJob);
      _;
  }
  
  modifier onlyValidMortgage(uint256 jobId){
      require(msg.value > jobData[jobId].salary/10);
      _;
  }
  
  modifier onlyValidJob(uint256 jobId){
      require(jobData[jobId].end == 0);
      require(jobData[jobId].start == 0);
      _;
  }

  function createJob(uint256 timeOut, string title, string description, string image)
  public onlyHaveFund onlyValidTimeOut(timeOut) payable returns(uint256 jobId)
  {
    // Saving a little gas by create a temporary object
    Job memory newJob;

    // Assign jobId
    jobId = totalJob;
    
    newJob.id = jobId;
    newJob.timeOut = timeOut;
    newJob.title = title;
    newJob.description = description; 
    newJob.salary = msg.value;
    newJob.creator = msg.sender;
    newJob.image = image;
    
    NewJob(jobId, msg.sender, msg.value, timeOut);
    
    // Append newJob to jobData
    jobData[totalJob++] = newJob;
    
    return jobId;
  }
 
    function takeJob (uint256 jobId)
    public onlyValidMortgage(jobId) onlyValidId(jobId) onlyValidJob(jobId)
    {
        TakeJob(jobId, msg.sender);
        
        jobData[jobId].start = block.timestamp;
    }
    
    function viewJob(uint256 jobId)
    public onlyValidId(jobId) constant returns (
        uint256 id,
        address creator,
        uint256 salary,
        uint256 start,
        uint256 end,
        uint256 timeOut,
        string title,
        string description
        ){
            Job memory jobReader = jobData[jobId];
            return (
                jobReader.id,
                jobReader.creator,
                jobReader.salary,
                jobReader.start,
                jobReader.end,
                jobReader.timeOut,
                jobReader.title,
                jobReader.description);
            
        }
}