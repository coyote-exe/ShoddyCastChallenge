using poekmoncsharp;
using System.Diagnostics;
Stopwatch sw = new Stopwatch();
sw.Start();
Console.WriteLine("Starting...");
long rolls = 1000000000;
var mainRNumberGenerator = new Random();
var cpucores = Environment.ProcessorCount;
long GPURolls = (rolls / 5) * 4;
long CPURolls = rolls - GPURolls;
long rollPerCpuThread = CPURolls / cpucores;
Task<int>[] answersTasks = new Task<int>[cpucores];
Console.WriteLine("total rolls:" + rolls);
Console.WriteLine("***CPU information***");
Console.WriteLine("CPU rolls:" + CPURolls);
Console.WriteLine("CPU cores:" + cpucores);
Console.WriteLine("CPU rolls per Thread:" + rollPerCpuThread);
Console.WriteLine("***GPU information***");
Console.WriteLine("GPU rolls:" + GPURolls);
Console.WriteLine("starting threads...");
for (int a = 0; a < cpucores; a++)
{
    Console.WriteLine("Starting thread {0}", a + 1);
    answersTasks[a] = Task.Run(() => executeRolls(rollPerCpuThread));
}
var gp = new ToGPU();
var gpu_res = gp.Send(GPURolls, mainRNumberGenerator.Next(1, Int32.MaxValue), false);
await Task.WhenAll(answersTasks);
var cpu_res = getResultsFromTasks(cpucores, answersTasks).Max();
Console.WriteLine("Highest Ones Roll from CPU: {0}", cpu_res);
Console.WriteLine("Highest Ones Roll from GPU: {0}", gpu_res);
Console.WriteLine("finished in {0} seconds", sw.Elapsed.TotalSeconds);
Console.ReadLine();

int executeRolls(long amount)
{
    var randomNumberGenerator = new Random();
    int[] numbers = { 0, 0, 0, 0 }; // numbers = [0,0,0,0]
    long rolls = 0;
    int maxOnes = 0;
    while (numbers[0] < 177 && rolls < amount)//while numbers[0] < 177 and rolls< 1000000000:
    {
        numbers = new int[] { 0, 0, 0, 0 }; // numbers = [0, 0, 0, 0]
        for (int i = 0; i < 231; i++) // for i in repeat(None, 231):
        {
            var roll = randomNumberGenerator.Next(1, 5); //roll = random.choice(items) -- "1 to 5" because for some reason the upper bound is exclusive while the lower bound is inclusive. more information at https://learn.microsoft.com/en-us/dotnet/api/system.random.next?view=net-8.0#system-random-next(system-int32-system-int32)
            numbers[roll - 1] = numbers[roll - 1] + 1; // numbers[roll - 1] = numbers[roll - 1] + 1
        }
        rolls = rolls + 1; // rolls = rolls + 1
        if (numbers[0] > maxOnes) // if numbers[0] > maxOnes:
            maxOnes = numbers[0]; // maxOnes = numbers[0]
    }
    Console.WriteLine("CPU thread ended");
    return maxOnes;
}

int[] getResultsFromTasks(int cores, Task<int>[] answersTasks)
{
    int[] answers = new int[cores];
    for (int a = 0; a < cores; a++)
        answers[a] = answersTasks[a].Result;
    return answers;
}