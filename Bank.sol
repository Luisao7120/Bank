pragma solidity ^0.4.25;

contract Bank 
{
	// 银行的地址
	address bank;
	// 银行和企业的账户存款
	mapping(address => uint)public balance;
	function check_balance(address a)public returns(uint)
	{
		return balance[a];
	}
	// 现在的时间
	uint public now_time=0;

	// 合同
	struct Trust_contract
	{
		uint start_time; // 合同开始时间
		uint end_time; // 合同结束时间
		address address_from; // 合同的from方
		address address_to; // 合同的to方
		uint amount; // 合同总额度
		uint used; // 被使用的额度
	}
	Trust_contract[] public contracts;

	constructor()public
	{
		bank=msg.sender;
		balance[msg.sender]=999999;
	}

	function deposit(uint money)public
	{
		balance[msg.sender]+=money;
	}

	// 签署信任合同的函数
	function trusted(uint end_time,uint money,uint password)public
	{
		// 判断密码是否正确
		if(password!=1234)return;
		// 判断银行是否存在
		if(bank==0x0000000000000000000000000000000000000000)return;
		// 判断时间是否合法
		if(end_time<now_time)return;

		// 添加信任合同
		Trust_contract memory t=Trust_contract(now_time,end_time,bank,msg.sender,money,0);
		contracts.push(t);
	}

	// 企业间交易的函数
	function deal(address address_to,uint money)public
	{
		// 判断交易的to方是不是bank，如果是则终止交易
		if(address_to==bank)return;

		// 遍历发起交易的企业的合同，判断余额是否足够
		uint mount=0; // mount用于储存总余额
		bool flag=false;
		for(uint i=0;i<contracts.length;i++)
		{
			if(contracts[i].address_to==msg.sender)mount+=(contracts[i].amount-contracts[i].used);
			if(mount>money)
			{
				flag=true;
				break;
			}
		}

		// 如果总余额不足，终止交易
		if(flag==false)return;
		
		// 开始交易，遍历所有合同。合同的to方才有权利使用这份余额
		// money是用户输入的值，代表两家企业间交易的额度
		for(i=0;i<contracts.length;i++)
		{
			if(contracts[i].address_to==msg.sender)
			{
				// 如果一份合同的余额就足够，直接给这份合同的used加上money，并新建一份额度为money的普通合同，结束遍历
				if(contracts[i].amount-contracts[i].used>=money)
				{
					contracts[i].used+=money;

					Trust_contract memory t=Trust_contract(now_time,contracts[i].end_time,msg.sender,address_to,money,0);
					contracts.push(t);

					break;
				}
				// 如果一份合同的余额不够，就用光这份合同的余额，并新建一份额度为所用余额的普通合同，更新money用于下一个循环
				else
				{
					money-=(contracts[i].amount-contracts[i].used);
					
					t=Trust_contract(now_time,contracts[i].end_time,msg.sender,address_to,contracts[i].amount-contracts[i].used,0);
					contracts.push(t);

					contracts[i].used=contracts[i].amount;
				}
			}
		}
	}

	// 企业从银行“取款”（相当于贷款或者融资）的函数
	function loan(uint money)public
	{
		// 判断交易的to方是不是bank，如果是则终止交易
		if(msg.sender==bank)return;

		// 遍历发起交易的企业的合同，判断余额是否足够
		uint mount=0; // mount用于储存总余额
		bool flag=false;
		for(uint i=0;i<contracts.length;i++)
		{
			if(contracts[i].address_to==msg.sender)mount+=(contracts[i].amount-contracts[i].used);
			if(mount>=money)
			{
				flag=true;
				break;
			}
		}

		// 如果总余额不足，终止交易
		if(flag==false)return;
		
		// 开始“取款”，遍历所有合同。合同的to方才有权利使用这份余额
		// money是用户输入的值，代表msg.sender想“取款”的额度
		for(i=0;i<contracts.length;i++)
		{
			if(contracts[i].address_to==msg.sender)
			{
				// 如果一份合同的余额就足够，直接给这份合同的used加上money，并给msg.sender的账户加上money，结束遍历
				if(contracts[i].amount-contracts[i].used>=money)
				{
					contracts[i].used+=money;

					balance[msg.sender]+=money;
					balance[bank]-=money;

					break;
				}
				// 如果一份合同的余额不够，就用光这份合同的余额，并给msg.sender的账户加上money，更新money用于下一个循环
				else
				{
					money-=(contracts[i].amount-contracts[i].used);
					
					balance[msg.sender]+=money;
					balance[bank]-=money;

					contracts[i].used=contracts[i].amount;
				}
			}
		}
	}
    
	// mount用于储存总欠款
    mapping(address => uint)mount;
	// 企业还款的函数 + 日期前进的函数
	function repay(uint time)public
	{
		// 判断前进的日期是否大于现在的日期
		if(time<=now_time)return;

		// 初始化mount
		for(uint i=0;i<contracts.length;i++)mount[contracts[i].address_to]=0;
		// 计算总欠款
		for(i=0;i<contracts.length;i++)
		{
			if(contracts[i].end_time<time)
			{
				if(contracts[i].address_from==bank)
				{
					mount[contracts[i].address_to]+=contracts[i].used;
				}
			}
		}
		// 比较总欠款和账户存款，如果存款不够就不能还款 + 日期前进
		for(i=0;i<contracts.length;i++)
		{
			if(mount[contracts[i].address_to]>balance[contracts[i].address_to])
			{
				return;
			}
		}
		
		for(i=0;i<contracts.length;i++)
		{
			if(contracts[i].end_time<time)
			{
				// 如果合同的from方是bank，这是一份信任合同，就从to方的账户上扣钱
				if(contracts[i].address_from==bank)
				{
					balance[contracts[i].address_to]-=contracts[i].used;
					// 不要忘记删除合同
					delete contracts[i];
				}
				// 否则这是一份普通合同，就在to方的账户上加钱
				else
				{
					balance[contracts[i].address_to]+=(contracts[i].amount-contracts[i].used);
					// 不要忘记删除合同
					delete contracts[i];
				}
			}
		}

		now_time=time;
	}
}