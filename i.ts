async function ticketText(name: string, value: number): Promise<string> {
  let str: string = `${name} has ${value} euros.`;
  await new Promise((resolve, reject) => {
    setTimeout(() => {
      resolve(true);
    }, 1000);
  });
  return str;
}

async function main() {
  var text = await ticketText("Tommy", 100);
  console.log(text);
}

var li = [1, 4, 5, 6];
li.filter((n) => n % 2 == 0);
// [4, 6]
li[li.length - 1];
//4
