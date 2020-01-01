pragma solidity ^0.4.25;

contract Bank 
{
	// ���еĵ�ַ
	address bank;
	// ���к���ҵ���˻����
	mapping(address => uint)public balance;
	function check_balance(address a)public returns(uint)
	{
		return balance[a];
	}
	// ���ڵ�ʱ��
	uint public now_time=0;

	// ��ͬ
	struct Trust_contract
	{
		uint start_time; // ��ͬ��ʼʱ��
		uint end_time; // ��ͬ����ʱ��
		address address_from; // ��ͬ��from��
		address address_to; // ��ͬ��to��
		uint amount; // ��ͬ�ܶ��
		uint used; // ��ʹ�õĶ��
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

	// ǩ�����κ�ͬ�ĺ���
	function trusted(uint end_time,uint money,uint password)public
	{
		// �ж������Ƿ���ȷ
		if(password!=1234)return;
		// �ж������Ƿ����
		if(bank==0x0000000000000000000000000000000000000000)return;
		// �ж�ʱ���Ƿ�Ϸ�
		if(end_time<now_time)return;

		// ������κ�ͬ
		Trust_contract memory t=Trust_contract(now_time,end_time,bank,msg.sender,money,0);
		contracts.push(t);
	}

	// ��ҵ�佻�׵ĺ���
	function deal(address address_to,uint money)public
	{
		// �жϽ��׵�to���ǲ���bank�����������ֹ����
		if(address_to==bank)return;

		// ���������׵���ҵ�ĺ�ͬ���ж�����Ƿ��㹻
		uint mount=0; // mount���ڴ��������
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

		// ��������㣬��ֹ����
		if(flag==false)return;
		
		// ��ʼ���ף��������к�ͬ����ͬ��to������Ȩ��ʹ��������
		// money���û������ֵ������������ҵ�佻�׵Ķ��
		for(i=0;i<contracts.length;i++)
		{
			if(contracts[i].address_to==msg.sender)
			{
				// ���һ�ݺ�ͬ�������㹻��ֱ�Ӹ���ݺ�ͬ��used����money�����½�һ�ݶ��Ϊmoney����ͨ��ͬ����������
				if(contracts[i].amount-contracts[i].used>=money)
				{
					contracts[i].used+=money;

					Trust_contract memory t=Trust_contract(now_time,contracts[i].end_time,msg.sender,address_to,money,0);
					contracts.push(t);

					break;
				}
				// ���һ�ݺ�ͬ�����������ù���ݺ�ͬ�������½�һ�ݶ��Ϊ����������ͨ��ͬ������money������һ��ѭ��
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

	// ��ҵ�����С�ȡ����൱�ڴ���������ʣ��ĺ���
	function loan(uint money)public
	{
		// �жϽ��׵�to���ǲ���bank�����������ֹ����
		if(msg.sender==bank)return;

		// ���������׵���ҵ�ĺ�ͬ���ж�����Ƿ��㹻
		uint mount=0; // mount���ڴ��������
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

		// ��������㣬��ֹ����
		if(flag==false)return;
		
		// ��ʼ��ȡ����������к�ͬ����ͬ��to������Ȩ��ʹ��������
		// money���û������ֵ������msg.sender�롰ȡ��Ķ��
		for(i=0;i<contracts.length;i++)
		{
			if(contracts[i].address_to==msg.sender)
			{
				// ���һ�ݺ�ͬ�������㹻��ֱ�Ӹ���ݺ�ͬ��used����money������msg.sender���˻�����money����������
				if(contracts[i].amount-contracts[i].used>=money)
				{
					contracts[i].used+=money;

					balance[msg.sender]+=money;
					balance[bank]-=money;

					break;
				}
				// ���һ�ݺ�ͬ�����������ù���ݺ�ͬ��������msg.sender���˻�����money������money������һ��ѭ��
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
    
	// mount���ڴ�����Ƿ��
    mapping(address => uint)mount;
	// ��ҵ����ĺ��� + ����ǰ���ĺ���
	function repay(uint time)public
	{
		// �ж�ǰ���������Ƿ�������ڵ�����
		if(time<=now_time)return;

		// ��ʼ��mount
		for(uint i=0;i<contracts.length;i++)mount[contracts[i].address_to]=0;
		// ������Ƿ��
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
		// �Ƚ���Ƿ����˻�����������Ͳ��ܻ��� + ����ǰ��
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
				// �����ͬ��from����bank������һ�����κ�ͬ���ʹ�to�����˻��Ͽ�Ǯ
				if(contracts[i].address_from==bank)
				{
					balance[contracts[i].address_to]-=contracts[i].used;
					// ��Ҫ����ɾ����ͬ
					delete contracts[i];
				}
				// ��������һ����ͨ��ͬ������to�����˻��ϼ�Ǯ
				else
				{
					balance[contracts[i].address_to]+=(contracts[i].amount-contracts[i].used);
					// ��Ҫ����ɾ����ͬ
					delete contracts[i];
				}
			}
		}

		now_time=time;
	}
}