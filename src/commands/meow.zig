const std = @import("std");
const Command = @import("Command.zig");
const discord = @import("discord");

pub const command: Command = .{
    .name = "meow",
    .description = "Wanna see a cat?",
    .onExecute = onExecute,
};

pub fn onExecute(client: discord.Client, interaction: Command.Interaction) !void {
    var prng: std.Random.DefaultPrng = .init(interaction.id);
    const random = prng.random();

    const cat_index = random.int(usize);
    const cat = cats[cat_index % cats.len];
    const emoji = emojis[cat_index % emojis.len];

    var buf: [256]u8 = undefined;
    const content = try std.fmt.bufPrintSentinel(&buf, "{s} [⠀]({s})", .{ emoji, cat }, 0);

    try interaction.respond(client, content);
}

const emojis: []const []const u8 = &.{ "😺", "😸", "😹", "😻", "😼", "😽", "🙀", "😿", "😾", "🐕", "🐩", "🐱", "🐈‍⬛", "🦁", "🐯", "🐅", "🐆" };

const cats: []const []const u8 = &.{
    "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%2Fid%2FOIP.YFmJZ1hmnsbXTGc7zCaiPgHaE8%3Fpid%3DApi&f=1&ipt=079d5a0f5f4cd6ea00894c4762fab8e748cbc084b633839e236bd1f4ac3a3fca&ipo=images",
    "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%2Fid%2FOIP.MNW1ABA7J4r-lA_hGE_soAEsCp%3Fpid%3DApi&f=1&ipt=1b4f82290c616bd460b9d1d2598043920a236a020240f7aa76e83de3ce90b401&ipo=images",
    "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%2Fid%2FOIP.5mHzEG-6x73hJA6bXFkoQQHaE8%3Fpid%3DApi&f=1&ipt=1a6bf97fcb5c5ba9ee322d36fe4d83f362c3aa875ec84bd8fe84f18fabde6fc3&ipo=images",
    "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%2Fid%2FOIP.F4Pa8bkVE5EWtwb3OIRZiAHaE7%3Fpid%3DApi&f=1&ipt=870218e4d17db1c1cde7ab79d27ae37cea144d2bd661f68f41e1d1357aef85f2&ipo=images",
    "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%2Fid%2FOIP.yvj61X0dbFFF8viA7fmKcAHaEV%3Fpid%3DApi&f=1&ipt=1b4027ec7f6cb4bf0973509b701d7af42dcd1ecf664530a493c910a3e72e5b85&ipo=images",
    "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%2Fid%2FOIP.jZZtpWrFEocE-Rptm2fL3AHaGp%3Fpid%3DApi&f=1&ipt=da75e9212e9140fb21944c1676ddbf1ef24e74acded41ab0eaf3fd106d5a6a47&ipo=images",
    "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%2Fid%2FOIP.99-Ub0vugOXKqI7ZrOpiLwHaE8%3Fpid%3DApi&f=1&ipt=4cfbefb0b0d6fb7932c2b3430e2a04440cde9965b00303c661408f84a1f3e04f&ipo=images",
    "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse3.mm.bing.net%2Fth%2Fid%2FOIP.ZS6zTvqdDt4aO2XzuD63OAHaEZ%3Fpid%3DApi&f=1&ipt=7b3db697c4c898ff10a345051772b8acda508cab074d3a2ccb4425a648b54925&ipo=images",
    "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%2Fid%2FOIP.1zY_WjFMf_H4rtbc1GvSUgHaE8%3Fpid%3DApi&f=1&ipt=8ad5a7871de5afbf7705a7a091325a7f1f844c58a3456a4fe272a95d015cb5ff&ipo=images",
    "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%2Fid%2FOIP.bxiSY9URA5QDvV-N-AMSfwHaE8%3Fpid%3DApi&f=1&ipt=a8ee7d9dafa1fe30fd29b8ffbd85c68a366a3a700303a7763bc7f4fb72eed7e7&ipo=images",
    "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse4.mm.bing.net%2Fth%2Fid%2FOIP.uMztOpgp93UUOwltvk9MvQHaFj%3Fpid%3DApi&f=1&ipt=24a6d4e8348a62bfd6fad2451f9e0e2cc8a557461551b51cea67b094bb74f065&ipo=images",
    "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%2Fid%2FOIP.3nr6t-hvjdpQUPH0wdyWUwHaEc%3Fpid%3DApi&f=1&ipt=b4a5ed3a48a320d75c24205c05bc34ab90ff2beb2053fec5fee54419ff3acb58&ipo=images",
    "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse3.mm.bing.net%2Fth%2Fid%2FOIP.gaPN5fStRRmzPsyDOM-EAgHaJ4%3Fpid%3DApi&f=1&ipt=9f2d4d4f90e83ab004ec2b4bd03bdc083d629490b88dd7fb8e4f870c8a422c35&ipo=images",
    "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%2Fid%2FOIP.-IArq9ZxV_nX8RII3YE2mgHaE7%3Fpid%3DApi&f=1&ipt=da833ac9b3ec4467f1f5550569b487235abde7cdc40d377fd6b34e75bd7c3e9e&ipo=images",
    "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%2Fid%2FOIP.pTlNTFyGRbmvHJN65rKmsQHaE8%3Fpid%3DApi&f=1&ipt=d8f961ec1aedbc943b72a0e9e60ba309e6a751cc929d9954d54784fb338d72cf&ipo=images",
    "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse1.mm.bing.net%2Fth%2Fid%2FOIP.TJID4RWOeBHEmXdU_GZp6QHaHa%3Fpid%3DApi&f=1&ipt=dccd259101ca0f99930776af3b98b391303b56d0aad8a642cd71f054ac578833&ipo=images",
    "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse3.mm.bing.net%2Fth%2Fid%2FOIP.y-pYxn7POH0AmUemX2HtawAAAA%3Fpid%3DApi&f=1&ipt=912972038a3ea5d6144171c472828110dae53252c4c2b4fe741d19531da78ced&ipo=images",
    "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse4.mm.bing.net%2Fth%2Fid%2FOIP.6SQmkPhiq9NPcd32JwCsbAHaK6%3Fpid%3DApi&f=1&ipt=5221afd6392183b6ed6964e983799cfa3ea403743412af121dd3a0b6d94daddf&ipo=images",
    "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse2.mm.bing.net%2Fth%2Fid%2FOIP.p-_iWklhi1VXOIQaJDq8BQHaFC%3Fpid%3DApi&f=1&ipt=4bd2118bcb48c1c24fd023f830bd0266fa8f718e565b4be637e7c653b26331e4&ipo=images",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTkL4WZvGAk07aV5n1YRnUnR0xGmciI1FLLZw&s",
    "https://i.natgeofe.com/n/548467d8-c5f1-4551-9f58-6817a8d2c45e/NationalGeographic_2572187_16x9.jpg?w=1200",
    "https://upload.wikimedia.org/wikipedia/commons/4/4d/Cat_November_2010-1a.jpg",
    "https://cdn.omlet.com/images/originals/breed_abyssinian_cat.jpg",
    "https://images.squarespace-cdn.com/content/v1/607f89e638219e13eee71b1e/1684821560422-SD5V37BAG28BURTLIXUQ/michael-sum-LEpfefQf4rU-unsplash.jpg",
    "https://cdn.7tv.app/emote/01JNTSHDH983SR2SCGYTWXBMYA/4x.webp",
    "https://tenor.com/view/gn-chat-cat-good-night-chat-kitty-gif-1739596971726164224",
    "https://tenor.com/view/roomba-walls-cat-roomba-cat-i-am-in-your-walls-gif-24840588",
    "https://tenor.com/view/happy-cat-gif-10804346947536782797",
    "https://tenor.com/view/cat-cute-cat-cat-dance-cute-cat-dance-ai-cat-gif-15064057413633942575",
    "https://tenor.com/view/qazqaz-gif-6790593549618684130",
    "https://tenor.com/view/cat-gif-16258174987336597266",
    "https://tenor.com/view/silly-reaction-meme-stan-twitter-funny-stressed-gif-7713976294327515532",
    "https://tenor.com/view/happy-catto-gif-15346413526676920650",
    "https://media.tenor.com/h8TMXz1liyUAAAAd/image.gif",
};
