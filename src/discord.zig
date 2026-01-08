pub const u64unix_ms = u64;
pub const u64snowflake = u64;
pub const u64bitmask = u64;
pub const DiscordResponse = struct {
    code: i64, // HTTP status code (C 'long' → i64 on most platforms)
    reason: ?[*:0]const u8, // C 'const char*' → optional null-terminated string
    text: ?[*:0]const u8, // raw response body (optional pointer)
    size: usize, // size of text
    // http: ua_resp,            // replace with your Zig equivalent of `struct ua_resp`
};
pub const struct_discord_response = extern struct {
    data: ?*anyopaque = null,
    keep: ?*const anyopaque = null,
    code: ErrorCode = @import("std").mem.zeroes(ErrorCode),
};
pub const ccord_szbuf = extern struct {
    start: [*]u8,
    size: usize = 0,
};
pub const ccord_szbuf_readonly = extern struct {
    start: [*]const u8,
    size: usize = 0,
};
pub const ccord_szbuf_reusable = extern struct {
    start: [*]u8,
    size: usize = 0,
    realsize: usize = 0,
};
pub const strings = extern struct {
    size: c_int = 0,
    array: [*][*:0]u8,
    realsize: c_int = 0,
};
pub const json_values = extern struct {
    size: c_int = 0,
    array: [*][*:0]u8,
    realsize: c_int = 0,
};
pub const snowflakes = extern struct {
    size: c_int = 0,
    array: [*]u64snowflake,
    realsize: c_int = 0,
};
pub const bitmasks = extern struct {
    size: c_int = 0,
    array: [*]u64bitmask,
    realsize: c_int = 0,
};
pub const integers = extern struct {
    size: c_int = 0,
    array: [*]c_int,
    realsize: c_int = 0,
};
pub const premium_types = enum(c_uint) {
    NONE = 0,
    NITRO_CLASSIC = 1,
    NITRO = 2,
};
pub const User = extern struct {
    id: u64snowflake = 0,
    name: [*:0]const u8 = "",
    discriminator: [*:0]const u8 = "",
    avatar: [*:0]const u8 = "",
    is_bot: bool = false,
    system: bool = false,
    mfa_enabled: bool = false,
    banner: [*c]u8 = null,
    accent_color: c_int = 0,
    locale: [*c]u8 = null,
    verified: bool = false,
    email: [*c]u8 = null,
    flags: u64bitmask = 0,
    premium_type: premium_types = .NONE,
    public_flags: u64bitmask = 0,

    pub const Return = struct {
        data: ?*anyopaque = null,
        cleanup: ?*const fn (client: Client, data: ?*anyopaque) callconv(.c) void = null,
        keep: ?*const anyopaque = null,
        high_priority: bool = false,
        fail: ?*const fn (client: Client, resp: [*c]struct_discord_response) callconv(.c) void = null,
        done: ?*const fn (client: Client, resp: [*c]struct_discord_response, ret: ?*const User) callconv(.c) void = null,
        sync: ?*User = null,
    };
};
pub const membership_state = enum(c_uint) {
    INVITED = 1,
    ACCEPTED = 2,
};
pub const team_member = extern struct {
    membership_state: membership_state,
    permissions: [*c]bitmasks = null,
    team_id: u64snowflake = 0,
    user: *User,
};
pub const team_members = extern struct {
    size: c_int = 0,
    array: [*]team_member,
    realsize: c_int = 0,
};
pub const team = extern struct {
    icon: [*c]u8 = null,
    id: u64snowflake = 0,
    members: [*c]team_members = null,
    name: [*c]u8 = null,
    owner_user_id: u64snowflake = 0,
};
pub const application = extern struct {
    id: u64snowflake = 0,
    name: [*c]u8 = null,
    icon: [*c]u8 = null,
    description: [*c]u8 = null,
    rpc_origins: [*c]strings = null,
    bot_public: bool = false,
    bot_require_code_grant: bool = false,
    terms_of_service_url: [*c]u8 = null,
    privacy_policy_url: [*c]u8 = null,
    owner: *User,
    summary: [*c]u8 = null,
    verify_key: [*c]u8 = null,
    team: [*c]team = null,
    guild_id: u64snowflake = 0,
    primary_sku_id: u64snowflake = 0,
    slug: [*c]u8 = null,
    cover_image: [*c]u8 = null,
    flags: u64bitmask = 0,
};
pub const install_params = extern struct {
    scopes: [*c]strings = null,
    permissions: u64bitmask = 0,
};
pub const audit_log_events = enum(c_uint) {
    GUILD_UPDATE = 1,
    CHANNEL_CREATE = 10,
    CHANNEL_UPDATE = 11,
    CHANNEL_DELETE = 12,
    CHANNEL_OVERWRITE_CREATE = 13,
    CHANNEL_OVERWRITE_UPDATE = 14,
    CHANNEL_OVERWRITE_DELETE = 15,
    MEMBER_KICK = 20,
    MEMBER_PRUNE = 21,
    MEMBER_BAN_ADD = 22,
    MEMBER_BAN_REMOVE = 23,
    MEMBER_UPDATE = 24,
    MEMBER_ROLE_UPDATE = 25,
    MEMBER_MOVE = 26,
    MEMBER_DISCONNECT = 27,
    BOT_ADD = 28,
    ROLE_CREATE = 30,
    ROLE_UPDATE = 31,
    ROLE_DELETE = 32,
    INVITE_CREATE = 40,
    INVITE_UPDATE = 41,
    INVITE_DELETE = 42,
    WEBHOOK_CREATE = 50,
    WEBHOOK_UPDATE = 51,
    WEBHOOK_DELETE = 52,
    EMOJI_CREATE = 60,
    EMOJI_UPDATE = 61,
    EMOJI_DELETE = 62,
    MESSAGE_DELETE = 72,
    MESSAGE_BULK_DELETE = 73,
    MESSAGE_PIN = 74,
    MESSAGE_UNPIN = 75,
    INTEGRATION_CREATE = 80,
    INTEGRATION_UPDATE = 81,
    INTEGRATION_DELETE = 82,
    STAGE_INSTANCE_CREATE = 83,
    STAGE_INSTANCE_UPDATE = 84,
    STAGE_INSTANCE_DELETE = 85,
    STICKER_CREATE = 90,
    STICKER_UPDATE = 91,
    STICKER_DELETE = 92,
    GUILD_SCHEDULED_EVENT_CREATE = 100,
    GUILD_SCHEDULED_EVENT_UPDATE = 101,
    GUILD_SCHEDULED_EVENT_DELETE = 102,
    THREAD_CREATE = 110,
    THREAD_UPDATE = 111,
    THREAD_DELETE = 112,
    APPLICATION_COMMAND_PERMISSION_UPDATE = 121,
    AUTO_MODERATION_RULE_CREATE = 140,
    AUTO_MODERATION_RULE_UPDATE = 141,
    AUTO_MODERATION_RULE_DELETE = 142,
    AUTO_MODERATION_BLOCK_MESSAGE = 143,
};
pub const audit_log_change = extern struct {
    new_value: [*:0]u8 = null,
    old_value: [*:0]u8 = null,
    key: [*:0]u8 = null,
};
pub const audit_log_changes = extern struct {
    size: c_int = 0,
    array: [*]audit_log_change,
    realsize: c_int = 0,
};
pub const optional_audit_entry_info = extern struct {
    channel_id: u64snowflake = 0,
    count: [*c]u8 = null,
    delete_member_days: [*c]u8 = null,
    id: u64snowflake = 0,
    members_removed: [*c]u8 = null,
    message_id: u64snowflake = 0,
    role_name: [*c]u8 = null,
    type: [*c]u8 = null,
};
pub const optional_audit_entry_infos = extern struct {
    size: c_int = 0,
    array: [*]optional_audit_entry_info,
    realsize: c_int = 0,
};
pub const audit_log_entry = extern struct {
    target_id: u64snowflake = 0,
    changes: [*c]audit_log_changes = null,
    user_id: u64snowflake = 0,
    id: u64snowflake = 0,
    action_type: audit_log_events,
    options: [*c]optional_audit_entry_infos = null,
    reason: [*c]u8 = null,
};
pub const audit_log_entries = extern struct {
    size: c_int = 0,
    array: [*]audit_log_entry,
    realsize: c_int = 0,
};
pub const guild_scheduled_event_privacy_level = enum(c_uint) {
    GUILD_ONLY = 2,
};
pub const guild_scheduled_event_status = enum(c_uint) {
    SCHEDULED = 1,
    ACTIVE = 2,
    COMPLETED = 3,
    CANCELED = 4,
};
pub const guild_scheduled_event_entity_types = enum(c_uint) {
    STAGE_INSTANCE = 1,
    VOICE = 2,
    EXTERNAL = 3,
};
pub const guild_scheduled_event_entity_metadata = extern struct {
    location: [*c]u8 = null,
};
pub const guild_scheduled_event = extern struct {
    id: u64snowflake = 0,
    guild_id: u64snowflake = 0,
    channel_id: u64snowflake = 0,
    creator_id: u64snowflake = 0,
    name: [*c]u8 = null,
    description: [*c]u8 = null,
    scheduled_start_time: u64unix_ms = 0,
    scheduled_end_time: u64unix_ms = 0,
    privacy_level: guild_scheduled_event_privacy_level,
    status: guild_scheduled_event_status,
    entity_type: guild_scheduled_event_entity_types,
    entity_id: u64snowflake = 0,
    entity_metadata: [*c]guild_scheduled_event_entity_metadata = null,
    creator: *User,
    user_count: c_int = 0,
    image: [*c]u8 = null,
};
pub const guild_scheduled_events = extern struct {
    size: c_int = 0,
    array: [*]guild_scheduled_event,
    realsize: c_int = 0,
};
pub const integration_expire_behaviors = enum(c_uint) {
    REMOVE_ROLE = 0,
    KICK = 1,
};
pub const integration_account = extern struct {
    id: [*:0]u8,
    name: [*:0]u8,
};
pub const integration_application = extern struct {
    id: u64snowflake = 0,
    name: [*c]u8 = null,
    icon: [*c]u8 = null,
    description: [*c]u8 = null,
    summary: [*c]u8 = null,
    bot: *User,
};
pub const integration = extern struct {
    id: u64snowflake = 0,
    name: [*c]u8 = null,
    type: [*c]u8 = null,
    enabled: bool = false,
    syncing: bool = false,
    role_id: u64snowflake = 0,
    enable_emoticons: bool = false,
    expire_behavior: integration_expire_behaviors,
    expire_grace_period: c_int = 0,
    user: *User,
    account: [*c]integration_account = null,
    synced_at: u64unix_ms = 0,
    subscriber_count: c_int = 0,
    revoked: bool = false,
    application: [*c]integration_application = null,
    guild_id: u64snowflake = 0,
};
pub const integrations = extern struct {
    size: c_int = 0,
    array: [*]integration,
    realsize: c_int = 0,
};
pub const channel_types = enum(c_uint) {
    GUILD_TEXT = 0,
    DM = 1,
    GUILD_VOICE = 2,
    GROUP_DM = 3,
    GUILD_CATEGORY = 4,
    GUILD_ANNOUNCEMENT = 5, // Same as GUILD_NEWS
    GUILD_STORE = 6,
    ANNOUNCEMENT_THREAD = 10, // Same as GUILD_NEWS_THREAD
    GUILD_PUBLIC_THREAD = 11,
    GUILD_PRIVATE_THREAD = 12,
    GUILD_STAGE_VOICE = 13,
    GUILD_DIRECTORY = 14,
    GUILD_FORUM = 15,
    GUILD_MEDIA = 16,
};
pub const overwrite = extern struct {
    id: u64snowflake = 0,
    type: c_int = 0,
    allow: u64bitmask = 0,
    deny: u64bitmask = 0,
};
pub const overwrites = extern struct {
    size: c_int = 0,
    array: [*]overwrite,
    realsize: c_int = 0,
};
pub const users = extern struct {
    size: c_int = 0,
    array: [*]User,
    realsize: c_int = 0,
};
pub const thread_metadata = extern struct {
    archived: bool = false,
    auto_archive_duration: c_int = 0,
    archive_timestamp: u64unix_ms = 0,
    locked: bool = false,
    invitable: bool = false,
    create_timestamp: u64unix_ms = 0,
};
pub const guild_member = extern struct {
    user: *User,
    nick: ?[*:0]const u8 = null,
    avatar: [*:0]const u8,
    roles: *snowflakes,
    joined_at: u64unix_ms = 0,
    premium_since: u64unix_ms = 0,
    deaf: bool = false,
    muted: bool = false,
    pending: bool = false,
    permissions: u64bitmask = 0,
    communication_disabled_until: u64unix_ms = 0,
    guild_id: u64snowflake = 0,
};
pub const thread_member = extern struct {
    id: u64snowflake = 0,
    user_id: u64snowflake = 0,
    join_timestamp: u64unix_ms = 0,
    flags: u64bitmask = 0,
    member: [*c]guild_member = null,
    guild_id: u64snowflake = 0,
};
pub const thread_tag = extern struct {
    id: u64snowflake = 0,
    name: [*c]u8 = null,
    moderated: bool = false,
    emoji_id: u64snowflake = 0,
    emoji_name: [*c]u8 = null,
};
pub const thread_tags = extern struct {
    size: c_int = 0,
    array: [*]thread_tag,
    realsize: c_int = 0,
};
pub const thread_default_reaction = extern struct {
    emoji_id: u64snowflake = 0,
    emoji_name: [*c]u8 = null,
};
pub const sort_order_types = enum(c_uint) {
    LATEST_ACTIVITY = 0,
    CREATION_DATE = 1,
};
pub const forum_layout_types = enum(c_uint) {
    NOT_SET = 0,
    LIST_VIEW = 1, // Same as GALLERY_VIEW
};
pub const Channel = extern struct {
    id: u64snowflake = 0,
    type: channel_types,
    guild_id: u64snowflake = 0,
    position: c_int = 0,
    permission_overwrites: [*c]overwrites = null,
    name: [*:0]const u8,
    topic: ?[*:0]const u8 = null,
    nsfw: bool = false,
    last_message_id: u64snowflake = 0,
    bitrate: c_int = 0,
    user_limit: c_int = 0,
    rate_limit_per_user: c_int = 0,
    recipients: *users,
    icon: [*c]u8 = null,
    owner_id: u64snowflake = 0,
    application_id: u64snowflake = 0,
    managed: bool = false,
    parent_id: u64snowflake = 0,
    last_pin_timestamp: u64unix_ms = 0,
    rtc_region: [*c]u8 = null,
    voice_quality_mode: c_int = 0,
    message_count: c_int = 0,
    member_count: c_int = 0,
    thread_metadata: [*c]thread_metadata = null,
    member: [*c]thread_member = null,
    default_auto_archive_duration: c_int = 0,
    permissions: u64bitmask = 0,
    flags: u64bitmask = 0,
    total_message_sent: c_int = 0,
    available_tags: [*c]thread_tags = null,
    applied_tags: [*c]snowflakes = null,
    default_reaction_emoji: [*c]thread_default_reaction = null,
    default_thread_rate_limit_per_user: c_int = 0,
    default_sort_order: sort_order_types,
    default_forum_layout: forum_layout_types,
};
pub const channels = extern struct {
    size: c_int = 0,
    array: [*]Channel,
    realsize: c_int = 0,
};
pub const webhook_types = enum(c_uint) {
    INCOMING = 1,
    CHANNEL_FOLLOWER = 2,
    APPLICATION = 3,
};
pub const webhook = extern struct {
    id: u64snowflake = 0,
    type: webhook_types,
    guild_id: u64snowflake = 0,
    channel_id: u64snowflake = 0,
    user: *User,
    name: [*c]u8 = null,
    token: ?[*:0]u8 = null,
    application_id: u64snowflake = 0,
    source_channel: [*c]Channel = null,
    url: [*c]u8 = null,
};
pub const webhooks = extern struct {
    size: c_int = 0,
    array: [*]webhook,
    realsize: c_int = 0,
};
pub const audit_log = extern struct {
    audit_log_entries: [*c]audit_log_entries = null,
    guild_scheduled_events: [*c]guild_scheduled_events = null,
    integrations: [*c]integrations = null,
    threads: [*c]channels = null,
    users: *users,
    webhooks: [*c]webhooks = null,
};
pub const get_guild_audit_log = extern struct {
    user_id: u64snowflake = 0,
    action_type: c_int = 0,
    before: u64snowflake = 0,
    limit: c_int = 0,
};
pub const auto_moderation_trigger_types = enum(c_uint) {
    KEYWORD = 1,
    HARMFUL_LINK = 2,
    SPAM = 3,
    KEYWORD_PRESET = 4,
};
pub const auto_moderation_keyword_preset_types = enum(c_uint) {
    PROFANITY = 1,
    SEXUAL_CONTENT = 2,
    SLURS = 3,
};
pub const auto_moderation_event_types = enum(c_uint) {
    MESSAGE_SEND = 1,
};
pub const auto_moderation_action_types = enum(c_uint) {
    BLOCK_MESSAGE = 1,
    SEND_ALERT_MESSAGE = 2,
    TIMEOUT = 3,
};
pub const auto_moderation_trigger_metadata = extern struct {
    keyword_filter: [*c]strings = null,
    presets: [*c]integers = null,
};
pub const auto_moderation_action_metadata = extern struct {
    channel_id: u64snowflake = 0,
    duration_seconds: c_int = 0,
};
pub const auto_moderation_action = extern struct {
    type: auto_moderation_action_types,
    metadata: [*c]auto_moderation_action_metadata = null,
};
pub const auto_moderation_actions = extern struct {
    size: c_int = 0,
    array: [*]auto_moderation_action,
    realsize: c_int = 0,
};
pub const auto_moderation_rule = extern struct {
    id: u64snowflake = 0,
    guild_id: u64snowflake = 0,
    name: [*c]u8 = null,
    creator_id: u64snowflake = 0,
    event_type: auto_moderation_event_types,
    trigger_type: auto_moderation_trigger_types,
    actions: [*c]auto_moderation_actions = null,
    trigger_metadata: [*c]auto_moderation_trigger_metadata = null,
    enabled: bool = false,
    exempt_roles: [*c]snowflakes = null,
    exempt_channels: [*c]snowflakes = null,
};
pub const auto_moderation_rules = extern struct {
    size: c_int = 0,
    array: [*]auto_moderation_rule,
    realsize: c_int = 0,
};
pub const create_auto_moderation_rule = extern struct {
    reason: [*c]u8 = null,
    name: [*c]u8 = null,
    event_type: auto_moderation_event_types,
    trigger_type: auto_moderation_trigger_types,
    actions: [*c]auto_moderation_actions = null,
    trigger_metadata: [*c]auto_moderation_trigger_metadata = null,
    enabled: bool = false,
    exempt_roles: [*c]snowflakes = null,
    exempt_channels: [*c]snowflakes = null,
};
pub const modify_auto_moderation_rule = extern struct {
    reason: [*c]u8 = null,
    name: [*c]u8 = null,
    event_type: auto_moderation_event_types,
    trigger_metadata: [*c]auto_moderation_trigger_metadata = null,
    actions: [*c]auto_moderation_actions = null,
    enabled: bool = false,
    exempt_roles: [*c]snowflakes = null,
    exempt_channels: [*c]snowflakes = null,
};
pub const delete_auto_moderation_rule = extern struct {
    reason: [*:0]u8,
};
pub const invite_target_types = enum(c_uint) {
    STREAM = 1,
    EMBEDDED_APPLICATION = 2,
};
pub const verification_level = enum(c_uint) {
    NONE = 0,
    LOW = 1,
    MEDIUM = 2,
    HIGH = 3,
    VERY_HIGH = 4,
};

pub const message_notification_level = enum(c_uint) {
    ALL_MESSAGES = 0,
    ONLY_MESSAGES = 1,
    ALL_MEMBERS = 2,
};
pub const explicit_content_filter_level = enum(c_uint) {
    DISABLED = 0,
    MEMBERS_WITHOUT_ROLES = 1,
};
pub const role_tag = extern struct {
    bot_id: u64snowflake = 0,
    integration_id: u64snowflake = 0,
    premium_subscribe: bool = false,
};
pub const role = extern struct {
    id: u64snowflake = 0,
    name: [*c]u8 = null,
    color: c_int = 0,
    hoist: bool = false,
    icon: [*c]u8 = null,
    unicode_emoji: [*c]u8 = null,
    position: c_int = 0,
    permissions: u64bitmask = 0,
    managed: bool = false,
    mentionable: bool = false,
    tags: [*c]role_tag = null,
};
pub const roles = extern struct {
    size: c_int = 0,
    array: [*]role,
    realsize: c_int = 0,
};
pub const emoji = extern struct {
    id: u64snowflake = 0,
    name: [*:0]const u8,
    roles: ?*snowflakes = null,
    user: *User,
    require_colons: bool = false,
    managed: bool = false,
    animated: bool = false,
    available: bool = false,
};
pub const emojis = extern struct {
    size: c_int = 0,
    array: [*]emoji,
    realsize: c_int = 0,
};
pub const mfa_level = enum(c_uint) {
    NONE = 0,
    ELEVATED = 1,
};
pub const voice_state = extern struct {
    guild_id: u64snowflake = 0,
    channel_id: u64snowflake = 0,
    user_id: u64snowflake = 0,
    member: [*c]guild_member = null,
    session_id: [*c]u8 = null,
    deaf: bool = false,
    mute: bool = false,
    self_deaf: bool = false,
    self_mute: bool = false,
    self_stream: bool = false,
    self_video: bool = false,
    suppress: bool = false,
    request_to_speak_timestamp: u64unix_ms = 0,
};
pub const voice_states = extern struct {
    size: c_int = 0,
    array: [*]voice_state,
    realsize: c_int = 0,
};
pub const guild_members = extern struct {
    size: c_int = 0,
    array: [*]guild_member,
    realsize: c_int = 0,
};
pub const client_status = extern struct {
    desktop: [*c]u8 = null,
    mobile: [*c]u8 = null,
    web: [*c]u8 = null,
};
pub const activity_types = enum(c_uint) {
    GAME = 0,
    STREAMING = 1,
    LISTENING = 2,
    WATCHING = 3,
    CUSTOM = 4,
    COMPETING = 5,
};
pub const activity_timestamps = extern struct {
    start: u64unix_ms = 0,
    end: u64unix_ms = 0,
};
pub const activity_emoji = extern struct {
    name: [*c]u8 = null,
    id: u64snowflake = 0,
    animated: bool = false,
};
pub const activity_party = extern struct {
    id: [*c]u8 = null,
    size: [*c]integers = null,
};
pub const activity_assets = extern struct {
    large_image: [*c]u8 = null,
    large_text: [*c]u8 = null,
    small_image: [*c]u8 = null,
    small_text: [*c]u8 = null,
};
pub const activity_secrets = extern struct {
    join: [*c]u8 = null,
    spectate: [*c]u8 = null,
    match: [*c]u8 = null,
};
pub const activity_button = extern struct {
    label: [*:0]u8,
    url: [*:0]u8,
};
pub const activity_buttons = extern struct {
    size: c_int = 0,
    array: [*]activity_button,
    realsize: c_int = 0,
};
pub const activity = extern struct {
    name: [*c]u8 = null,
    type: activity_types,
    url: [*c]u8 = null,
    created_at: u64unix_ms = 0,
    timestamps: [*c]activity_timestamps = null,
    application_id: u64snowflake = 0,
    details: [*c]u8 = null,
    state: [*c]u8 = null,
    emoji: [*c]activity_emoji = null,
    party: [*c]activity_party = null,
    assets: [*c]activity_assets = null,
    secrets: [*c]activity_secrets = null,
    instance: bool = false,
    flags: u64bitmask = 0,
    buttons: [*c]activity_buttons = null,
};
pub const activities = extern struct {
    size: c_int = 0,
    array: [*]activity,
    realsize: c_int = 0,
};
pub const presence_update = extern struct {
    user: *User,
    guild_id: u64snowflake = 0,
    status: [*c]u8 = null,
    client_status: [*c]client_status = null,
    activities: [*c]activities = null,
    since: u64unix_ms = 0,
    afk: bool = false,
};
pub const presence_updates = extern struct {
    size: c_int = 0,
    array: [*]presence_update,
    realsize: c_int = 0,
};
pub const premium_tier = enum(c_uint) {
    NONE = 0,
    @"1" = 1,
    @"2" = 2,
    @"3" = 3,
};
pub const welcome_screen_channel = extern struct {
    channel_id: u64snowflake = 0,
    description: [*c]u8 = null,
    emoji_id: u64snowflake = 0,
    emoji_name: [*c]u8 = null,
};
pub const welcome_screen_channels = extern struct {
    size: c_int = 0,
    array: [*]welcome_screen_channel,
    realsize: c_int = 0,
};
pub const welcome_screen = extern struct {
    description: [*c]u8 = null,
    welcome_channels: [*c]welcome_screen_channels = null,
};
pub const guild_nsfw_level = enum(c_uint) {
    DEFAULT = 0,
    EXPLICIT = 1,
    SAFE = 2,
    AGE_RESTRICTED = 3,
};
pub const privacy_level = enum(c_uint) {
    PUBLIC = 1,
    GUILD_ONLY = 2,
};
pub const stage_instance = extern struct {
    id: u64snowflake = 0,
    guild_id: u64snowflake = 0,
    channel_id: u64snowflake = 0,
    topic: [*c]u8 = null,
    privacy_level: privacy_level,
    discoverable_disabled: bool = false,
};
pub const stage_instances = extern struct {
    size: c_int = 0,
    array: [*]stage_instance,
    realsize: c_int = 0,
};
pub const sticker_types = enum(c_uint) {
    STANDARD = 1,
    GUILD = 2,
};
pub const sticker_format_types = enum(c_uint) {
    PNG = 1,
    APNG = 2,
    LOTTIE = 3,
};
pub const sticker = extern struct {
    id: u64snowflake = 0,
    pack_id: u64snowflake = 0,
    name: [*c]u8 = null,
    description: [*c]u8 = null,
    tags: [*c]u8 = null,
    type: sticker_types,
    format_type: sticker_format_types,
    available: bool = false,
    guild_id: u64snowflake = 0,
    user: *User,
    sort_value: c_int = 0,
};
pub const stickers = extern struct {
    size: c_int = 0,
    array: [*]sticker,
    realsize: c_int = 0,
};
pub const guild = extern struct {
    id: u64snowflake = 0,
    name: [*c]u8 = null,
    icon: [*c]u8 = null,
    icon_hash: [*c]u8 = null,
    splash: [*c]u8 = null,
    discovery_splash: [*c]u8 = null,
    owner: bool = false,
    owner_id: u64snowflake = 0,
    permissions: u64bitmask = 0,
    afk_channel_id: u64snowflake = 0,
    afk_timeout: c_int = 0,
    widget_enabled: bool = false,
    widget_channel_id: u64snowflake = 0,
    verification_level: verification_level,
    default_message_notifications: message_notification_level,
    explicit_content_filter: explicit_content_filter_level,
    roles: [*c]roles = null,
    emojis: [*c]emojis = null,
    features: [*c]strings = null,
    mfa_level: mfa_level,
    application_id: u64snowflake = 0,
    system_channel_id: u64snowflake = 0,
    system_channel_flags: u64bitmask = 0,
    rules_channel_id: u64snowflake = 0,
    joined_at: u64unix_ms = 0,
    large: bool = false,
    unavailable: bool = false,
    member_count: c_int = 0,
    voice_states: [*c]voice_states = null,
    members: [*c]guild_members = null,
    channels: [*c]channels = null,
    threads: [*c]channels = null,
    presences: [*c]presence_updates = null,
    max_presences: c_int = 0,
    max_members: c_int = 0,
    vanity_url_code: [*c]u8 = null,
    description: [*c]u8 = null,
    banner: [*c]u8 = null,
    premium_tier: premium_tier,
    premium_subscription_count: c_int = 0,
    preferred_locale: [*c]u8 = null,
    public_updates_channel_id: u64snowflake = 0,
    max_video_channel_users: c_int = 0,
    approximate_member_count: c_int = 0,
    approximate_presence_count: c_int = 0,
    welcome_screen: [*c]welcome_screen = null,
    nsfw_level: guild_nsfw_level,
    stage_instances: [*c]stage_instances = null,
    stickers: [*c]stickers = null,
    guild_scheduled_events: [*c]guild_scheduled_events = null,
    premium_progress_bar_enabled: bool = false,
};
pub const invite_stage_instance = extern struct {
    members: [*c]guild_members = null,
    participant_count: c_int = 0,
    speaker_count: c_int = 0,
    topic: [*c]u8 = null,
};
pub const invite = extern struct {
    code: [*c]u8 = null,
    guild: [*c]guild = null,
    channel: [*c]Channel = null,
    inviter: *User,
    target_type: invite_target_types,
    target_user: *User,
    target_application: [*c]application = null,
    approximate_presence_count: c_int = 0,
    approximate_member_count: c_int = 0,
    expires_at: u64unix_ms = 0,
    stage_instance: [*c]invite_stage_instance = null,
    guild_scheduled_event: [*c]guild_scheduled_event = null,
};
pub const invites = extern struct {
    size: c_int = 0,
    array: [*]invite,
    realsize: c_int = 0,
};
pub const invite_metadata = extern struct {
    uses: c_int = 0,
    max_uses: c_int = 0,
    max_age: c_int = 0,
    temporary: bool = false,
    created_at: u64unix_ms = 0,
};
pub const get_invite = extern struct {
    with_counts: bool = false,
    with_expiration: bool = false,
    guild_scheduled_event_id: u64snowflake = 0,
};
pub const delete_invite = extern struct {
    reason: [*c]u8 = null,
};
pub const video_quality_modes = enum(c_uint) {
    AUTO = 1,
    FULL = 2,
};
pub const message_activity_types = enum(c_uint) {
    JOIN = 1,
    SPECTATE = 2,
    LISTEN = 3,
    JOIN_REQUEST = 5,
};
pub const message_activity = extern struct {
    type: message_activity_types,
    party_id: [*c]u8 = null,
};
pub const message_reference = extern struct {
    message_id: u64snowflake = 0,
    channel_id: u64snowflake = 0,
    guild_id: u64snowflake = 0,
    fail_if_not_exists: bool = false,
};
pub const attachment = extern struct {
    content: [*c]u8 = null,
    id: u64snowflake = 0,
    filename: [*c]u8 = null,
    description: [*c]u8 = null,
    content_type: [*c]u8 = null,
    size: usize = 0,
    url: [*c]u8 = null,
    proxy_url: [*c]u8 = null,
    height: c_int = 0,
    width: c_int = 0,
    ephemeral: bool = false,
    duration_secs: c_int = 0,
    waveform: [*c]u8 = null,
    flags: u64bitmask = 0,
};
pub const attachments = extern struct {
    size: c_int = 0,
    array: [*]attachment,
    realsize: c_int = 0,
};
pub const embed_footer = extern struct {
    text: [*c]u8 = null,
    icon_url: [*c]u8 = null,
    proxy_icon_url: [*c]u8 = null,
};
pub const embed_image = extern struct {
    url: [*c]u8 = null,
    proxy_url: [*c]u8 = null,
    height: c_int = 0,
    width: c_int = 0,
};
pub const embed_thumbnail = extern struct {
    url: [*c]u8 = null,
    proxy_url: [*c]u8 = null,
    height: c_int = 0,
    width: c_int = 0,
};
pub const embed_video = extern struct {
    url: [*c]u8 = null,
    proxy_url: [*c]u8 = null,
    height: c_int = 0,
    width: c_int = 0,
};
pub const embed_provider = extern struct {
    name: [*:0]u8,
    url: [*:0]u8,
};
pub const embed_author = extern struct {
    name: [*:0]u8,
    url: [*:0]u8,
    icon_url: [*c]u8 = null,
    proxy_icon_url: [*c]u8 = null,
};
pub const embed_field = extern struct {
    name: [*:0]u8,
    value: [*:0]u8,
    @"inline": bool = false,
};
pub const embed_fields = extern struct {
    size: c_int = 0,
    array: [*]embed_field,
    realsize: c_int = 0,
};
pub const embed = extern struct {
    title: [*c]u8 = null,
    type: [*c]u8 = null,
    description: [*c]u8 = null,
    url: [*c]u8 = null,
    timestamp: u64unix_ms = 0,
    color: c_int = 0,
    footer: [*c]embed_footer = null,
    image: [*c]embed_image = null,
    thumbnail: [*c]embed_thumbnail = null,
    video: [*c]embed_video = null,
    provider: [*c]embed_provider = null,
    author: [*c]embed_author = null,
    fields: [*c]embed_fields = null,
};
pub const embeds = extern struct {
    size: c_int = 0,
    array: [*]embed,
    realsize: c_int = 0,
};
pub const reaction_count_details = extern struct {
    burst: c_int = 0,
    normal: c_int = 0,
};
pub const reaction = extern struct {
    count: c_int = 0,
    count_details: [*c]reaction_count_details = null,
    me: bool = false,
    me_burst: bool = false,
    emoji: [*c]emoji = null,
    burst_colors: [*c]u8 = null,
};
pub const reactions = extern struct {
    size: c_int = 0,
    array: [*]reaction,
    realsize: c_int = 0,
};
pub const component_types = enum(c_uint) {
    ACTION_ROW = 1,
    BUTTON = 2,
    SELECT_MENU = 3,
    TEXT_INPUT = 4,
    USER_SELECT = 5,
    ROLE_SELECT = 6,
    MENTION_SELECT = 7,
    CHANNEL_SELECT = 8,
    SECTION = 9,
    TEXT_DISPLAY = 10,
    THUMBNAIL = 11,
    MEDIA_GALLERY = 12,
    FILE = 13,
    SEPARATOR = 14,
    CONTENT_INVENTORY_ENTRY = 16,
    CONTAINER = 17,
};
pub const component_styles = struct {
    pub const BUTTON_PRIMARY: c_uint = 1;
    pub const BUTTON_SECONDARY: c_uint = 2;
    pub const BUTTON_SUCCESS: c_uint = 3;
    pub const BUTTON_DANGER: c_uint = 4;
    pub const BUTTON_LINK: c_uint = 5;
    pub const TEXT_SHORT: c_uint = 1;
    pub const TEXT_PARAGRAPH: c_uint = 2;
};
pub const select_option = extern struct {
    label: [*c]u8 = null,
    value: [*c]u8 = null,
    description: [*c]u8 = null,
    emoji: [*c]emoji = null,
    Default: bool = false,
};
pub const select_options = extern struct {
    size: c_int = 0,
    array: [*]select_option,
    realsize: c_int = 0,
};
pub const component_media = extern struct {
    url: [*c]u8 = null,
};
pub const component_item = extern struct {
    media: [*c]component_media = null,
    description: [*c]u8 = null,
    spoiler: bool = false,
};
pub const component_items = extern struct {
    size: c_int = 0,
    array: [*]component_item,
    realsize: c_int = 0,
};
pub const COMPONENT_SPACING_SMALL: c_int = 1;
pub const COMPONENT_SPACING_LARGE: c_int = 2;
pub const component_spacing = c_uint;
pub const component = extern struct {
    id: u64snowflake = 0,
    type: component_types,
    custom_id: [*c]u8 = null,
    sku_id: u64snowflake = 0,
    style: component_styles,
    label: [*c]u8 = null,
    emoji: [*c]emoji = null,
    url: [*c]u8 = null,
    options: [*c]select_options = null,
    placeholder: [*c]u8 = null,
    min_values: c_int = 0,
    max_values: c_int = 0,
    components: [*c]components = null,
    min_length: c_int = 0,
    max_length: c_int = 0,
    required: bool = false,
    value: [*c]u8 = null,
    disabled: bool = false,
    accessory: [*c]component = null,
    media: [*c]component_media = null,
    content: [*c]u8 = null,
    description: [*c]u8 = null,
    spoiler: bool = false,
    items: [*c]component_items = null,
    file: [*c]component_media = null,
    divider: bool = false,
    spacing: component_spacing,
    color: c_int = 0,
};
pub const components = extern struct {
    size: c_int = 0,
    array: [*]component,
    realsize: c_int = 0,
};
pub const sticker_item = extern struct {
    id: u64snowflake = 0,
    name: [*c]u8 = null,
    format_type: sticker_format_types,
};
pub const sticker_items = extern struct {
    size: c_int = 0,
    array: [*]sticker_item,
    realsize: c_int = 0,
};
pub const role_subscription_data = extern struct {
    role_subscription_listing_id: u64snowflake = 0,
    tier_name: [*c]u8 = null,
    total_months_subscribed: c_int = 0,
    is_renewal: bool = false,
};
pub const resolved_data = extern struct {
    users: [*c]u8 = null,
    members: [*c]u8 = null,
    roles: [*c]u8 = null,
    channels: [*c]u8 = null,
    messages: [*c]u8 = null,
    attachments: [*c]u8 = null,
};
pub const Message = extern struct {
    id: u64snowflake = 0,
    channel_id: u64snowflake = 0,
    guild_id: u64snowflake = 0,
    author: *User,
    member: ?*guild_member = null,
    content: [*:0]const u8,
    timestamp: u64unix_ms = 0,
    edited_timestamp: u64unix_ms = 0,
    tts: bool = false,
    mention_everyone: bool = false,
    mentions: *users,
    mention_roles: [*c]snowflakes = null,
    mention_channels: [*c]channels = null,
    attachments: [*c]attachments = null,
    embeds: [*c]embeds = null,
    reactions: [*c]reactions = null,
    nonce: [*c]u8 = null,
    pinned: bool = false,
    webhook_id: u64snowflake = 0,
    type: Type,
    activity: [*c]message_activity = null,
    application: *application,
    application_id: u64snowflake = 0,
    message_reference: ?*message_reference = null,
    flags: u64bitmask = 0,
    referenced_message: ?*Message = null,
    interaction: *message_interaction,
    thread: [*c]Channel = null,
    components: [*c]components = null,
    sticker_items: [*c]sticker_items = null,
    stickers: [*c]stickers = null,
    position: c_int = 0,
    role_subscription_data: [*c]role_subscription_data = null,
    resolved: [*c]resolved_data = null,

    pub const Type = enum(c_uint) {
        DEFAULT = 0,
        RECIPIENT_ADD = 1,
        RECIPIENT_REMOVE = 2,
        CALL = 3,
        CHANNEL_NAME_CHANGE = 4,
        CHANNEL_ICON_CHANGE = 5,
        CHANNEL_PINNED_MESSAGE = 6,
        GUILD_MEMBER_JOIN = 7,
        USER_PREMIUM_GUILD_SUBSCRIPTION = 8,
        USER_PREMIUM_GUILD_SUBSCRIPTION_TIER_1 = 9,
        USER_PREMIUM_GUILD_SUBSCRIPTION_TIER_2 = 10,
        USER_PREMIUM_GUILD_SUBSCRIPTION_TIER_3 = 11,
        CHANNEL_FOLLOW_ADD = 12,
        GUILD_DISCOVERY_DISQUALIFIED = 14,
        GUILD_DISCOVERY_REQUALIFIED = 15,
        GUILD_DISCOVERY_GRACE_PERIOD_INITIAL_WARNING = 16,
        GUILD_DISCOVERY_GRACE_PERIOD_FINAL_WARNING = 17,
        THREAD_CREATED = 18,
        REPLY = 19,
        CHAT_INPUT_COMMAND = 20,
        THREAD_STARTER_MESSAGE = 21,
        GUILD_INVITE_REMINDER = 22,
        CONTEXT_MENU_COMMAND = 23,
        AUTO_MODERATION_ACTION = 24,
        ROLE_SUBSCRIPTION_PURCHASE = 25,
        INTERACTION_PREMIUM_UPSELL = 26,
        STAGE_START = 27,
        STAGE_END = 28,
        STAGE_SPEAKER = 29,
        STAGE_TOPIC = 31,
        GUILD_APPLICATION_PREMIUM_SUBSCRIPTION = 32,
    };

    pub const Create = extern struct {
        content: ?[*:0]const u8 = null,
        tts: bool = false,
        embeds: ?*embeds = null,
        allowed_mentions: [*c]allowed_mention = null,
        message_reference: [*c]message_reference = null,
        components: [*c]components = null,
        sticker_ids: [*c]snowflakes = null,
        attachments: [*c]attachments = null,
        flags: u64bitmask = 0,
        enforce_nonce: bool = false,
    };

    pub const Return = extern struct {
        sync: ?*Message = null,
        done: ?*const fn (msg: *Message, user_data: ?*anyopaque) callconv(.c) void = null,
        user_data: ?*anyopaque = null,
    };

    pub const message_interaction = extern struct {
        id: u64snowflake = 0,
        type: Interaction.Type,
        name: [*:0]u8,
        user: *User,
        member: ?*guild_member = null,
    };

    pub fn create(client: Client, channel_id: u64snowflake, params: Create) !void {
        return client.createMessage(channel_id, &params, null).toError();
    }
};
pub const messages = extern struct {
    size: c_int = 0,
    array: [*]Message,
    realsize: c_int = 0,
};
pub const followed_channel = extern struct {
    channel_id: u64snowflake = 0,
    webhook_id: u64snowflake = 0,
};
pub const thread_members = extern struct {
    size: c_int = 0,
    array: [*]thread_member,
    realsize: c_int = 0,
};
pub const channel_mention = extern struct {
    id: u64snowflake = 0,
    guild_id: u64snowflake = 0,
    type: channel_types,
    name: [*c]u8 = null,
};
pub const allowed_mention = extern struct {
    parse: [*c]strings = null,
    roles: [*c]snowflakes = null,
    users: [*c]snowflakes = null,
    replied_user: bool = false,
};
pub const thread_response_body = extern struct {
    threads: [*c]channels = null,
    members: [*c]thread_members = null,
    has_more: bool = false,
};
pub const modify_channel = extern struct {
    reason: [*c]u8 = null,
    name: [*c]u8 = null,
    type: channel_types,
    position: c_int = 0,
    topic: [*c]u8 = null,
    nsfw: bool = false,
    rate_limit_per_user: c_int = 0,
    user_limit: c_int = 0,
    permission_overwrites: [*c]overwrites = null,
    parent_id: u64snowflake = 0,
    rtc_region: [*c]u8 = null,
    video_quality_mode: c_int = 0,
    default_auto_archive_duration: c_int = 0,
    archived: bool = false,
    auto_archive_duration: c_int = 0,
    locked: bool = false,
    invitable: bool = false,
};
pub const delete_channel = extern struct {
    reason: [*c]u8 = null,
};
pub const get_channel_messages = extern struct {
    around: u64snowflake = 0,
    before: u64snowflake = 0,
    after: u64snowflake = 0,
    limit: c_int = 0,
};
pub const get_reactions = extern struct {
    after: u64snowflake = 0,
    limit: c_int = 0,
};
pub const edit_message = extern struct {
    content: [*c]u8 = null,
    embeds: [*c]embeds = null,
    flags: u64bitmask = 0,
    allowed_mentions: [*c]allowed_mention = null,
    components: [*c]components = null,
    attachments: [*c]attachments = null,
};
pub const delete_message = extern struct {
    reason: [*c]u8 = null,
};
pub const bulk_delete_messages = extern struct {
    reason: [*c]u8 = null,
    messages: [*c]snowflakes = null,
};
pub const edit_channel_permissions = extern struct {
    reason: [*c]u8 = null,
    allow: u64bitmask = 0,
    deny: u64bitmask = 0,
    type: c_int = 0,
};
pub const create_channel_invite = extern struct {
    reason: [*c]u8 = null,
    max_age: c_int = 0,
    max_uses: c_int = 0,
    temporary: bool = false,
    unique: bool = false,
    target_type: invite_target_types,
    target_user_id: u64snowflake = 0,
    target_application_id: u64snowflake = 0,
};
pub const delete_channel_permission = extern struct {
    reason: [*c]u8 = null,
};
pub const follow_news_channel = extern struct {
    webhook_channel_id: u64snowflake = 0,
};
pub const pin_message = extern struct {
    reason: [*c]u8 = null,
};
pub const unpin_message = extern struct {
    reason: [*c]u8 = null,
};
pub const group_dm_add_recipient = extern struct {
    access_token: ?[*:0]u8 = null,
    nick: [*c]u8 = null,
};
pub const start_thread_with_message = extern struct {
    reason: [*c]u8 = null,
    name: [*c]u8 = null,
    auto_archive_duration: c_int = 0,
    rate_limit_per_user: c_int = 0,
};
pub const start_thread_without_message = extern struct {
    reason: [*c]u8 = null,
    name: [*c]u8 = null,
    auto_archive_duration: c_int = 0,
    type: channel_types,
    invitable: bool = false,
    rate_limit_per_user: c_int = 0,
};
pub const list_active_threads = extern struct {
    threads: [*c]channels = null,
    members: [*c]thread_members = null,
    has_more: bool = false,
};
pub const create_guild_emoji = extern struct {
    reason: [*c]u8 = null,
    name: [*c]u8 = null,
    image: [*c]u8 = null,
    roles: [*c]snowflakes = null,
};
pub const modify_guild_emoji = extern struct {
    reason: [*c]u8 = null,
    name: [*c]u8 = null,
    image: [*c]u8 = null,
    roles: [*c]snowflakes = null,
};
pub const delete_guild_emoji = extern struct {
    reason: [*c]u8 = null,
};
pub const guilds = extern struct {
    size: c_int = 0,
    array: [*]guild,
    realsize: c_int = 0,
};
pub const guild_preview = extern struct {
    id: u64snowflake = 0,
    name: [*c]u8 = null,
    icon: [*c]u8 = null,
    splash: [*c]u8 = null,
    discovery_splash: [*c]u8 = null,
    emojis: [*c]emojis = null,
    features: [*c]strings = null,
    approximate_member_count: c_int = 0,
    approximate_presence_count: c_int = 0,
    description: [*c]u8 = null,
    stickers: [*c]stickers = null,
};
pub const guild_widget_settings = extern struct {
    reason: [*c]u8 = null,
    enabled: bool = false,
    channel_id: u64snowflake = 0,
};
pub const guild_widget = extern struct {
    id: u64snowflake = 0,
    name: [*c]u8 = null,
    instant_invite: [*c]u8 = null,
    channels: [*c]channels = null,
    members: *users,
    presence_count: c_int = 0,
};
pub const ban = extern struct {
    reason: [*c]u8 = null,
    user: *User,
};
pub const bans = extern struct {
    size: c_int = 0,
    array: [*]ban,
    realsize: c_int = 0,
};
pub const prune_count = extern struct {
    pruned: c_int = 0,
};
pub const create_guild = extern struct {
    reason: [*c]u8 = null,
    name: [*c]u8 = null,
    region: [*c]u8 = null,
    icon: [*c]u8 = null,
    verification_level: verification_level,
    default_message_notifications: message_notification_level,
    explicit_content_filter: explicit_content_filter_level,
    roles: [*c]roles = null,
    channels: [*c]channels = null,
    afk_channel_id: u64snowflake = 0,
    afk_timeout: c_int = 0,
    system_channel_id: u64snowflake = 0,
    system_channel_flags: u64bitmask = 0,
};
pub const modify_guild = extern struct {
    reason: [*c]u8 = null,
    name: [*c]u8 = null,
    verification_level: verification_level,
    default_message_notifications: message_notification_level,
    explicit_content_filter: explicit_content_filter_level,
    afk_channel_id: u64snowflake = 0,
    afk_timeout: c_int = 0,
    icon: [*c]u8 = null,
    owner_id: u64snowflake = 0,
    splash: [*c]u8 = null,
    discovery_splash: [*c]u8 = null,
    banner: [*c]u8 = null,
    system_channel_id: u64snowflake = 0,
    system_channel_flags: u64bitmask = 0,
    rules_channel_id: u64snowflake = 0,
    public_updates_channel_id: u64snowflake = 0,
    preferred_locale: [*c]u8 = null,
    features: [*c]strings = null,
    description: [*c]u8 = null,
    premium_progress_bar_enabled: bool = false,
};
pub const create_guild_channel = extern struct {
    reason: [*c]u8 = null,
    name: [*c]u8 = null,
    type: channel_types,
    topic: [*c]u8 = null,
    bitrate: c_int = 0,
    user_limit: c_int = 0,
    rate_limit_per_user: c_int = 0,
    position: c_int = 0,
    permission_overwrites: [*c]overwrites = null,
    parent_id: u64snowflake = 0,
    nsfw: bool = false,
};
pub const modify_guild_channel_position = extern struct {
    id: u64snowflake = 0,
    position: c_int = 0,
    lock_category: bool = false,
    parent_id: u64snowflake = 0,
};
pub const modify_guild_channel_positions = extern struct {
    size: c_int = 0,
    array: [*]modify_guild_channel_position,
    realsize: c_int = 0,
};
pub const list_active_guild_threads = extern struct {
    threads: [*c]channels = null,
    members: [*c]thread_members = null,
};
pub const list_guild_members = extern struct {
    limit: c_int = 0,
    after: u64snowflake = 0,
};
pub const search_guild_members = extern struct {
    query: [*c]u8 = null,
    limit: c_int = 0,
};
pub const add_guild_member = extern struct {
    access_token: ?[*:0]u8 = null,
    nick: [*c]u8 = null,
    roles: [*c]snowflakes = null,
    mute: bool = false,
    deaf: bool = false,
};
pub const modify_guild_member = extern struct {
    reason: [*c]u8 = null,
    nick: [*c]u8 = null,
    roles: [*c]snowflakes = null,
    mute: bool = false,
    deaf: bool = false,
    channel_id: u64snowflake = 0,
    communication_disabled_until: u64unix_ms = 0,
};
pub const modify_current_member = extern struct {
    reason: [*c]u8 = null,
    nick: [*c]u8 = null,
};
pub const modify_current_user_nick = extern struct {
    reason: [*c]u8 = null,
    nick: [*c]u8 = null,
};
pub const add_guild_member_role = extern struct {
    reason: [*c]u8 = null,
};
pub const remove_guild_member_role = extern struct {
    reason: [*c]u8 = null,
};
pub const remove_guild_member = extern struct {
    reason: [*c]u8 = null,
};
pub const create_guild_ban = extern struct {
    reason: [*c]u8 = null,
    delete_message_days: c_int = 0,
};
pub const remove_guild_ban = extern struct {
    reason: [*c]u8 = null,
};
pub const create_guild_role = extern struct {
    reason: [*c]u8 = null,
    name: [*c]u8 = null,
    permissions: u64bitmask = 0,
    color: c_int = 0,
    hoist: bool = false,
    icon: [*c]u8 = null,
    unicode_emoji: [*c]u8 = null,
    mentionable: bool = false,
};
pub const modify_guild_role_position = extern struct {
    id: u64snowflake = 0,
    position: c_int = 0,
};
pub const modify_guild_role_positions = extern struct {
    size: c_int = 0,
    array: [*]modify_guild_role_position,
    realsize: c_int = 0,
};
pub const modify_guild_role = extern struct {
    reason: [*c]u8 = null,
    name: [*c]u8 = null,
    permissions: u64bitmask = 0,
    color: c_int = 0,
    hoist: bool = false,
    icon: [*c]u8 = null,
    unicode_emoji: [*c]u8 = null,
    mentionable: bool = false,
};
pub const delete_guild_role = extern struct {
    reason: [*c]u8 = null,
};
pub const get_guild_prune_count = extern struct {
    days: c_int = 0,
    include_roles: [*c]snowflakes = null,
};
pub const begin_guild_prune = extern struct {
    reason: [*c]u8 = null,
    days: c_int = 0,
    compute_prune_count: bool = false,
    include_roles: [*c]snowflakes = null,
};
pub const delete_guild_integrations = extern struct {
    reason: [*c]u8 = null,
    days: c_int = 0,
    include_roles: [*c]snowflakes = null,
};
pub const get_guild_widget_image = extern struct {
    style: [*c]u8 = null,
};
pub const modify_guild_welcome_screen = extern struct {
    reason: [*c]u8 = null,
    enabled: bool = false,
    welcome_channels: [*c]welcome_screen_channels = null,
    description: [*c]u8 = null,
};
pub const modify_current_user_voice_state = extern struct {
    channel_id: u64snowflake = 0,
    suppress: bool = false,
    request_to_speak_timestamp: u64unix_ms = 0,
};
pub const modify_user_voice_state = extern struct {
    channel_id: u64snowflake = 0,
    suppress: bool = false,
};
pub const guild_scheduled_event_user = extern struct {
    guild_scheduled_event_id: u64snowflake = 0,
    user: *User,
    member: [*c]guild_member = null,
};
pub const guild_scheduled_event_users = extern struct {
    size: c_int = 0,
    array: [*]guild_scheduled_event_user,
    realsize: c_int = 0,
};
pub const list_guild_scheduled_events = extern struct {
    with_user_count: bool = false,
};
pub const create_guild_scheduled_event = extern struct {
    reason: [*c]u8 = null,
    channel_id: u64snowflake = 0,
    entity_metadata: [*c]guild_scheduled_event_entity_metadata = null,
    name: [*c]u8 = null,
    privacy_level: guild_scheduled_event_privacy_level,
    scheduled_start_time: u64unix_ms = 0,
    scheduled_end_time: u64unix_ms = 0,
    description: [*c]u8 = null,
    entity_type: guild_scheduled_event_entity_types,
    image: [*c]u8 = null,
};
pub const get_guild_scheduled_event = extern struct {
    with_user_count: bool = false,
};
pub const modify_guild_scheduled_event = extern struct {
    reason: [*c]u8 = null,
    channel_id: u64snowflake = 0,
    entity_metadata: [*c]guild_scheduled_event_entity_metadata = null,
    name: [*c]u8 = null,
    scheduled_start_time: u64unix_ms = 0,
    scheduled_end_time: u64unix_ms = 0,
    description: [*c]u8 = null,
    entity_type: guild_scheduled_event_entity_types,
    status: guild_scheduled_event_status,
    image: [*c]u8 = null,
};
pub const get_guild_scheduled_event_users = extern struct {
    limit: c_int = 0,
    with_member: bool = false,
    before: u64snowflake = 0,
    after: u64snowflake = 0,
};
pub const guild_template = extern struct {
    code: [*c]u8 = null,
    name: [*c]u8 = null,
    description: [*c]u8 = null,
    usage_count: c_int = 0,
    creator_id: u64snowflake = 0,
    creator: *User,
    created_at: u64unix_ms = 0,
    updated_at: u64unix_ms = 0,
    source_guild_id: u64snowflake = 0,
    serialized_source_guild: [*c]guild = null,
    is_dirty: bool = false,
};
pub const guild_templates = extern struct {
    size: c_int = 0,
    array: [*]guild_template,
    realsize: c_int = 0,
};
pub const create_guild_from_guild_template = extern struct {
    name: [*c]u8 = null,
    icon: [*c]u8 = null,
};
pub const create_guild_template = extern struct {
    name: [*c]u8 = null,
    description: [*c]u8 = null,
};
pub const modify_guild_template = extern struct {
    name: [*c]u8 = null,
    description: [*c]u8 = null,
};
pub const create_stage_instance = extern struct {
    reason: [*c]u8 = null,
    channel_id: u64snowflake = 0,
    topic: [*c]u8 = null,
    privacy_level: privacy_level,
};
pub const modify_stage_instance = extern struct {
    reason: [*c]u8 = null,
    topic: [*c]u8 = null,
    privacy_level: privacy_level,
};
pub const delete_stage_instance = extern struct {
    reason: [*c]u8 = null,
};
pub const sticker_pack = extern struct {
    id: u64snowflake = 0,
    stickers: [*c]stickers = null,
    name: [*c]u8 = null,
    sku_id: u64snowflake = 0,
    cover_sticker_id: u64snowflake = 0,
    description: [*c]u8 = null,
    banner_asset_id: u64snowflake = 0,
};
pub const sticker_packs = extern struct {
    size: c_int = 0,
    array: [*]sticker_pack,
    realsize: c_int = 0,
};
pub const list_nitro_sticker_packs = extern struct {
    sticker_packs: [*c]sticker_packs = null,
};
pub const create_guild_sticker = extern struct {
    reason: [*c]u8 = null,
    name: [*c]u8 = null,
    description: [*c]u8 = null,
    tags: [*c]u8 = null,
    file: [*c]attachment = null,
};
pub const modify_guild_sticker = extern struct {
    name: [*c]u8 = null,
    description: [*c]u8 = null,
    tags: [*c]u8 = null,
};
pub const delete_guild_sticker = extern struct {
    reason: [*c]u8 = null,
};
pub const VISIBILITY_NONE: c_int = 0;
pub const VISIBILITY_EVERYONE: c_int = 1;
pub const visibility_types = c_uint;
pub const connection = extern struct {
    id: u64snowflake = 0,
    name: [*c]u8 = null,
    type: [*c]u8 = null,
    revoked: bool = false,
    integrations: [*c]integrations = null,
    verified: bool = false,
    friend_sync: bool = false,
    show_activity: bool = false,
    visibility: visibility_types,
};
pub const connections = extern struct {
    size: c_int = 0,
    array: [*]connection,
    realsize: c_int = 0,
};
pub const modify_current_user = extern struct {
    username: [*c]u8 = null,
    avatar: [*c]u8 = null,
};
pub const get_current_user_guilds = extern struct {
    before: u64snowflake = 0,
    after: u64snowflake = 0,
    limit: c_int = 0,
};
pub const create_dm = extern struct {
    recipient_id: u64snowflake = 0,
};
pub const create_group_dm = extern struct {
    access_tokens: [*c]snowflakes = null,
    nicks: [*c]strings = null,
};
pub const voice_region = extern struct {
    id: [*c]u8 = null,
    name: [*c]u8 = null,
    optimal: bool = false,
    deprecated: bool = false,
    custom: bool = false,
};
pub const voice_regions = extern struct {
    size: c_int = 0,
    array: [*]voice_region,
    realsize: c_int = 0,
};
pub const create_webhook = extern struct {
    reason: [*c]u8 = null,
    name: [*c]u8 = null,
    avatar: [*c]u8 = null,
};
pub const modify_webhook = extern struct {
    reason: [*c]u8 = null,
    name: [*c]u8 = null,
    avatar: [*c]u8 = null,
    channel_id: u64snowflake = 0,
};
pub const delete_webhook = extern struct {
    reason: [*c]u8 = null,
};
pub const modify_webhook_with_token = extern struct {
    name: [*:0]u8,
    avatar: ?[*:0]u8 = null,
};
pub const execute_webhook = extern struct {
    wait: bool = false,
    thread_id: u64snowflake = 0,
    content: [*c]u8 = null,
    username: [*c]u8 = null,
    avatar_url: [*c]u8 = null,
    tts: bool = false,
    embeds: [*c]embeds = null,
    allowed_mentions: [*c]allowed_mention = null,
    components: [*c]components = null,
    attachments: [*c]attachments = null,
    flags: u64bitmask = 0,
};
pub const get_webhook_message = extern struct {
    thread_id: u64snowflake = 0,
};
pub const edit_webhook_message = extern struct {
    thread_id: u64snowflake = 0,
    content: [*c]u8 = null,
    embeds: [*c]embeds = null,
    allowed_mentions: [*c]allowed_mention = null,
    components: [*c]components = null,
    attachments: [*c]attachments = null,
};
pub const delete_webhook_message = extern struct {
    thread_id: u64snowflake = 0,
};
pub const gateway_close_opcodes = enum(c_uint) {
    UNKNOWN_ERROR = 4000,
    UNKNOWN_OPCODE = 4001,
    DECODE_ERROR = 4002,
    NOT_AUTHENTICATED = 4003,
    AUTHENTICATION_FAILED = 4004,
    ALREADY_AUTHENTICATED = 4005,
    INVALID_SEQUENCE = 4007,
    RATE_LIMITED = 4008,
    SESSION_TIMED_OUT = 4009,
    INVALID_SHARD = 4010,
    SHARDING_REQUIRED = 4011,
    INVALID_API_VERSION = 4012,
    INVALID_INTENTS = 4013,
    DISALLOWED_INTENTS = 4014,
    RECONNECT = 4900,
};
pub const gateway_opcodes = enum(c_uint) {
    DISPATCH = 0,
    HEARTBEAT = 1,
    IDENTIFY = 2,
    PRESENCE_UPDATE = 3,
    VOICE_STATE_UPDATE = 4,
    RESUME = 6,
    RECONNECT = 7,
    REQUEST_GUILD_MEMBERS = 8,
    INVALID_SESSION = 9,
    HELLO = 10,
    HEARTBEAT_ACK = 11,
};
pub const identify_connection = extern struct {
    os: ?[*:0]u8 = null,
    browser: ?[*:0]u8 = null,
    device: ?[*:0]u8 = null,
};
pub const identify = extern struct {
    token: ?[*:0]u8 = null,
    properties: [*c]identify_connection = null,
    compress: bool = false,
    large_threshold: c_int = 0,
    shard: [*c]integers = null,
    presence: [*c]presence_update = null,
    intents: u64bitmask = 0,
};
pub const @"resume" = extern struct {
    token: ?[*:0]u8 = null,
    session_id: [*c]u8 = null,
    seq: c_int = 0,
};
pub const RequestGuildMembers = extern struct {
    guild_id: u64snowflake = 0,
    query: [*c]u8 = null,
    limit: c_int = 0,
    presences: bool = false,
    user_ids: [*c]snowflakes = null,
    nonce: [*c]u8 = null,
};
pub const UpdateVoiceState = extern struct {
    guild_id: u64snowflake = 0,
    channel_id: u64snowflake = 0,
    self_mute: bool = false,
    self_deaf: bool = false,
};
pub const Ready = extern struct {
    v: c_int = 0,
    user: *User,
    guilds: *guilds,
    session_id: [*c]u8 = null,
    shard: [*c]integers = null,
    application: *application,
};
pub const auto_moderation_action_execution = extern struct {
    guild_id: u64snowflake = 0,
    action: [*c]auto_moderation_action = null,
    rule_trigger_type: auto_moderation_trigger_types,
    user_id: u64snowflake = 0,
    channel_id: u64snowflake = 0,
    message_id: u64snowflake = 0,
    alert_system_message_id: u64snowflake = 0,
    content: [*c]u8 = null,
    matched_keyword: [*c]u8 = null,
    matched_content: [*c]u8 = null,
};
pub const thread_list_sync = extern struct {
    guild_id: u64snowflake = 0,
    channel_ids: [*c]snowflakes = null,
    threads: [*c]channels = null,
    members: [*c]thread_members = null,
};
pub const thread_members_update = extern struct {
    id: u64snowflake = 0,
    guild_id: u64snowflake = 0,
    member_count: c_int = 0,
    added_members: [*c]thread_members = null,
    removed_member_ids: [*c]snowflakes = null,
};
pub const channel_pins_update = extern struct {
    guild_id: u64snowflake = 0,
    channel_id: u64snowflake = 0,
    last_pin_timestamp: u64unix_ms = 0,
};
pub const guild_ban_add = extern struct {
    guild_id: u64snowflake = 0,
    user: *User,
};
pub const guild_ban_remove = extern struct {
    guild_id: u64snowflake = 0,
    user: *User,
};
pub const guild_emojis_update = extern struct {
    guild_id: u64snowflake = 0,
    emojis: [*c]emojis = null,
};
pub const guild_stickers_update = extern struct {
    guild_id: u64snowflake = 0,
    stickers: [*c]stickers = null,
};
pub const guild_integrations_update = extern struct {
    guild_id: u64snowflake = 0,
};
pub const guild_member_remove = extern struct {
    guild_id: u64snowflake = 0,
    user: *User,
};
pub const guild_member_update = extern struct {
    guild_id: u64snowflake = 0,
    roles: [*c]snowflakes = null,
    user: *User,
    nick: [*c]u8 = null,
    avatar: [*c]u8 = null,
    joined_at: u64unix_ms = 0,
    premium_since: u64unix_ms = 0,
    deaf: bool = false,
    mute: bool = false,
    pending: bool = false,
    communication_disabled_until: u64unix_ms = 0,
};
pub const guild_members_chunk = extern struct {
    guild_id: u64snowflake = 0,
    members: [*c]guild_members = null,
    chunk_index: c_int = 0,
    chunk_count: c_int = 0,
    not_found: [*c]snowflakes = null,
    presences: [*c]presence_updates = null,
    nonce: [*c]u8 = null,
};
pub const guild_role_create = extern struct {
    guild_id: u64snowflake = 0,
    role: [*c]role = null,
};
pub const guild_role_update = extern struct {
    guild_id: u64snowflake = 0,
    role: [*c]role = null,
};
pub const guild_role_delete = extern struct {
    guild_id: u64snowflake = 0,
    role_id: u64snowflake = 0,
};
pub const guild_scheduled_event_user_add = extern struct {
    guild_scheduled_event_id: u64snowflake = 0,
    user_id: u64snowflake = 0,
    guild_id: u64snowflake = 0,
};
pub const guild_scheduled_event_user_remove = extern struct {
    guild_scheduled_event_id: u64snowflake = 0,
    user_id: u64snowflake = 0,
    guild_id: u64snowflake = 0,
};
pub const integration_delete = extern struct {
    id: u64snowflake = 0,
    guild_id: u64snowflake = 0,
    application_id: u64snowflake = 0,
};
pub const invite_create = extern struct {
    channel_id: u64snowflake = 0,
    code: [*c]u8 = null,
    created_at: u64unix_ms = 0,
    guild_id: u64snowflake = 0,
    inviter: *User,
    max_age: c_int = 0,
    max_uses: c_int = 0,
    target_type: invite_target_types,
    target_user: *User,
    target_application: [*c]application = null,
    temporary: bool = false,
    uses: c_int = 0,
};
pub const invite_delete = extern struct {
    channel_id: u64snowflake = 0,
    guild_id: u64snowflake = 0,
    code: [*c]u8 = null,
};
pub const message_delete = extern struct {
    id: u64snowflake = 0,
    channel_id: u64snowflake = 0,
    guild_id: u64snowflake = 0,
};
pub const message_delete_bulk = extern struct {
    ids: [*c]snowflakes = null,
    channel_id: u64snowflake = 0,
    guild_id: u64snowflake = 0,
};
pub const message_reaction = struct {
    pub const Add = extern struct {
        user_id: u64snowflake = 0,
        channel_id: u64snowflake = 0,
        message_id: u64snowflake = 0,
        guild_id: u64snowflake = 0,
        member: ?*guild_member = null,
        emoji: *emoji,
    };
    pub const Remove = extern struct {
        user_id: u64snowflake = 0,
        channel_id: u64snowflake = 0,
        message_id: u64snowflake = 0,
        guild_id: u64snowflake = 0,
        emoji: *emoji,
    };
    pub const RemoveAll = extern struct {
        channel_id: u64snowflake = 0,
        message_id: u64snowflake = 0,
        guild_id: u64snowflake = 0,
    };
    pub const RemoveEmoji = extern struct {
        channel_id: u64snowflake = 0,
        guild_id: u64snowflake = 0,
        message_id: u64snowflake = 0,
        emoji: *emoji,
    };
};
pub const typing_start = extern struct {
    channel_id: u64snowflake = 0,
    guild_id: u64snowflake = 0,
    user_id: u64snowflake = 0,
    timestamp: u64unix_ms = 0,
    member: [*c]guild_member = null,
};
pub const voice_server_update = extern struct {
    token: ?[*:0]u8 = null,
    guild_id: u64snowflake = 0,
    endpoint: [*c]u8 = null,
};
pub const webhooks_update = extern struct {
    guild_id: u64snowflake = 0,
    channel_id: u64snowflake = 0,
};
pub const session_start_limit = extern struct {
    total: c_int = 0,
    remaining: c_int = 0,
    reset_after: c_int = 0,
    max_concurrency: c_int = 0,
};
pub const auth_response = extern struct {
    application: [*c]application = null,
    scopes: [*c]strings = null,
    expires: u64unix_ms = 0,
    user: *User,
};
pub const voice_close_opcodes = enum(c_uint) {
    UNKNOWN_OPCODE = 4001,
    DECODE_ERROR = 4002,
    NOT_AUTHENTICATED = 4003,
    AUTHENTICATION_FAILED = 4004,
    ALREADY_AUTHENTICATED = 4005,
    INVALID_SESSION = 4006,
    SESSION_TIMED_OUT = 4009,
    SERVER_NOT_FOUND = 4011,
    UNKNOWN_PROTOCOL = 4012,
    DISCONNECTED = 4014,
    SERVER_CRASH = 4015,
    UNKNOWN_ENCRYPTION_MODE = 4016,
};
pub const voice_opcodes = enum(c_uint) {
    IDENTIFY = 0,
    SELECT_PROTOCOL = 1,
    READY = 2,
    HEARTBEAT = 3,
    SESSION_DESCRIPTION = 4,
    SPEAKING = 5,
    HEARTBEAT_ACK = 6,
    RESUME = 7,
    HELLO = 8,
    RESUMED = 9,
    CLIENT_DISCONNECT = 13,
    CODEC = 14,
};
pub const application_command_option_types = enum(c_uint) {
    SUB_COMMAND = 1,
    SUB_COMMAND_GROUP = 2,
    STRING = 3,
    INTEGER = 4,
    BOOLEAN = 5,
    USER = 6,
    CHANNEL = 7,
    ROLE = 8,
    MENTIONABLE = 9,
    NUMBER = 10,
    ATTACHMENT = 11,
};
pub const application_command_permission_types = enum(c_uint) {
    ROLE = 1,
    USER = 2,
    CHANNEL = 3,
};
pub const application_command_option_choice = extern struct {
    name: [*c]u8 = null,
    value: [*c]u8 = null,
};
pub const application_command_option_choices = extern struct {
    size: c_int = 0,
    array: [*]application_command_option_choice,
    realsize: c_int = 0,
};
pub const application_command_option = extern struct {
    type: application_command_option_types,
    name: [*c]u8 = null,
    description: [*c]u8 = null,
    required: bool = false,
    choices: [*c]application_command_option_choices = null,
    options: [*c]application_command_options = null,
    channel_types: [*c]integers = null,
    min_value: [*c]u8 = null,
    max_value: [*c]u8 = null,
    autocomplete: bool = false,
};
pub const application_command_options = extern struct {
    size: c_int = 0,
    array: [*]application_command_option = undefined,
    realsize: c_int = 0,
};
pub const ApplicationCommand = extern struct {
    id: u64snowflake = 0,
    type: Type,
    application_id: u64snowflake = 0,
    guild_id: u64snowflake = 0,
    name: [*c]u8 = null,
    description: [*c]u8 = null,
    options: [*c]application_command_options = null,
    default_member_permissions: u64bitmask = 0,
    dm_permission: bool = false,
    default_permission: bool = false,
    version: u64snowflake = 0,

    pub const Type = enum(c_uint) {
        CHAT_INPUT = 1,
        USER = 2,
        MESSAGE = 3,
    };

    pub const Return = struct {
        sync: ?*ApplicationCommand = null,
        done: ?*const fn (cmd: *ApplicationCommand, user_data: ?*anyopaque) void = null,
        user_data: ?*anyopaque = null,
    };
};
pub const application_commands = extern struct {
    size: c_int = 0,
    array: [*]ApplicationCommand,
    realsize: c_int = 0,
};
pub const application_command_interaction_data_options = extern struct {
    size: c_int = 0,
    array: [*]application_command_interaction_data_option,
    realsize: c_int = 0,
};
pub const application_command_interaction_data_option = extern struct {
    name: [*c]u8 = null,
    type: application_command_option_types,
    value: [*c]u8 = null,
    options: [*c]application_command_interaction_data_options = null,
    focused: bool = false,
};
pub const application_command_permission = extern struct {
    id: u64snowflake = 0,
    type: application_command_permission_types,
    permission: bool = false,
};
pub const application_command_permissions = extern struct {
    size: c_int = 0,
    array: [*]application_command_permission,
    realsize: c_int = 0,
};
pub const guild_application_command_permission = extern struct {
    id: u64snowflake = 0,
    application_id: u64snowflake = 0,
    guild_id: u64snowflake = 0,
    permissions: [*c]application_command_permissions = null,
};
pub const guild_application_command_permissions = extern struct {
    size: c_int = 0,
    array: [*]guild_application_command_permission,
    realsize: c_int = 0,
};
pub const create_global_application_command = extern struct {
    name: [*c]u8 = null,
    description: [*c]u8 = null,
    options: [*c]application_command_options = null,
    default_member_permissions: u64bitmask = 0,
    dm_permission: bool = false,
    default_permission: bool = false,
    type: ApplicationCommand.Type,
};
pub const edit_global_application_command = extern struct {
    name: [*c]u8 = null,
    description: [*c]u8 = null,
    options: [*c]application_command_options = null,
    default_member_permissions: u64bitmask = 0,
    dm_permission: bool = false,
    default_permission: bool = false,
};
pub const edit_guild_application_command = extern struct {
    name: [*c]u8 = null,
    description: [*c]u8 = null,
    options: [*c]application_command_options = null,
    default_member_permissions: u64bitmask = 0,
    default_permission: bool = false,
};
pub const bulk_overwrite_guild_application_commands = extern struct {
    id: u64snowflake = 0,
    name: [*c]u8 = null,
    name_localizations: [*c]strings = null,
    description: [*c]u8 = null,
    description_localizations: [*c]strings = null,
    options: [*c]application_command_options = null,
    default_member_permissions: u64bitmask = 0,
    dm_permission: bool = false,
    type: ApplicationCommand.Type,
};
pub const Interaction = extern struct {
    id: u64snowflake = 0,
    application_id: u64snowflake = 0,
    type: Type,
    data: ?*Data,
    guild_id: u64snowflake = 0,
    channel_id: u64snowflake = 0,
    member: [*c]guild_member = null,
    user: *User,
    token: [*:0]u8,
    version: c_int = 0,
    message: [*c]Message = null,
    locale: [*c]u8 = null,
    guild_locale: [*c]u8 = null,

    pub const Type = enum(c_uint) {
        PING = 1,
        APPLICATION_COMMAND = 2,
        MESSAGE_COMPONENT = 3,
        APPLICATION_COMMAND_AUTOCOMPLETE = 4,
        MODAL_SUBMIT = 5,
    };

    pub const Data = extern struct {
        id: u64snowflake = 0,
        name: [*:0]const u8,
        type: ApplicationCommand.Type,
        resolved: [*c]resolved_data = null,
        options: [*c]application_command_interaction_data_options = null,
        custom_id: [*c]const u8 = null,
        component_type: component_types,
        values: [*c]strings = null,
        target_id: u64snowflake = 0,
        components: [*c]components = null,
    };

    pub const Response = extern struct {
        type: CallbackType = .CHANNEL_MESSAGE_WITH_SOURCE,
        data: *const interaction_callback_data,

        pub const Return = extern struct { // TODO: fix?
            data: ?*anyopaque = null,
            cleanup: ?*const fn (client: Client, data: *void) callconv(.c) void = null,
            keep: ?*const anyopaque = null,
            high_priority: bool = false,
            fail: ?*const fn (client: Client, resp: *Response) callconv(.c) void = null,
            done: ?*const fn (client: Client, resp: *Response, ret: *const Response) callconv(.c) void,
            sync: ?*Response,
        };
    };

    pub const CallbackType = enum(c_uint) {
        PONG = 1,
        CHANNEL_MESSAGE_WITH_SOURCE = 4,
        DEFERRED_CHANNEL_MESSAGE_WITH_SOURCE = 5,
        DEFERRED_UPDATE_MESSAGE = 6,
        UPDATE_MESSAGE = 7,
        APPLICATION_COMMAND_AUTOCOMPLETE_RESULT = 8,
        MODAL = 9,
    };

    pub fn respond(self: @This(), client: Client, response: Response, @"return": ?*Response.Return) !void {
        try client.createInteractionResponse(self.id, self.token, &response, @"return").toError();
    }
};
pub const interaction_callback_data = extern struct {
    components: [*c]components = null,
    tts: bool = false,
    content: [*:0]const u8,
    embeds: ?*embeds = null,
    flags: u64bitmask = 0,
    attachments: [*c]attachments = null,
    choices: [*c]application_command_option_choices = null,
    custom_id: [*c]u8 = null,
    title: [*c]u8 = null,
};
pub const edit_original_interaction_response = extern struct {
    thread_id: u64snowflake = 0,
    content: [*c]u8 = null,
    embeds: [*c]embeds = null,
    allowed_mentions: [*c]allowed_mention = null,
    components: [*c]components = null,
    attachments: [*c]attachments = null,
};
pub const create_followup_message = extern struct {
    wait: bool = false,
    thread_id: u64snowflake = 0,
    avatar_url: [*c]u8 = null,
    tts: bool = false,
    embeds: [*c]embeds = null,
    allowed_mentions: [*c]allowed_mention = null,
    components: [*c]components = null,
    attachments: [*c]attachments = null,
    flags: u64bitmask = 0,
};
pub const edit_followup_message = extern struct {
    thread_id: u64snowflake = 0,
    content: [*c]u8 = null,
    embeds: [*c]embeds = null,
    allowed_mentions: [*c]allowed_mention = null,
    components: [*c]components = null,
    attachments: [*c]attachments = null,
};

pub const CreateGlobalApplicationCommand = struct {
    name: [*:0]const u8,
    description: [*:0]const u8,
    options: ?*application_command_options = null,
    default_member_permissions: u64bitmask = 0,
    dm_permission: bool = false,
    default_permission: bool = true,
    type: ApplicationCommand.Type,

    pub const Return = ApplicationCommand.Return;
};

pub const CreateGuildApplicationCommand = struct {
    name: [*:0]const u8,
    description: [*:0]const u8,
    options: ?*application_command_options = null,
    default_member_permissions: u64bitmask = 0,
    dm_permission: bool = false,
    default_permission: bool = true,
    type: ApplicationCommand.Type,

    pub const Return = extern struct {
        user_data: ?*anyopaque = null,
        cleanup: ?*const fn (client: Client, user_data: *anyopaque) callconv(.c) void = null,
        keep: ?*const anyopaque = null,
        high_priority: bool = false,
        fail: ?*const fn (client: Client, ret: *Return) callconv(.c) void = null,
        done: ?*const fn (client: Client, ret: *Return) callconv(.c) void = null,
        sync: ?*CreateGuildApplicationCommand = null,
    };
};

pub const discord_ev_scheduler = ?*const fn (client: *Client, data: [*]const u8, size: usize, event: gateway_events) callconv(.c) event_scheduler;

pub const gateway_events = enum(c_uint) {
    NONE = 0,
    READY = 1,
    RESUMED = 2,
    RECONNECT = 3,
    INVALID_SESSION = 4,
    APPLICATION_COMMAND_PERMISSIONS_UPDATE = 5,
    AUTO_MODERATION_RULE_CREATE = 6,
    AUTO_MODERATION_RULE_UPDATE = 7,
    AUTO_MODERATION_RULE_DELETE = 8,
    AUTO_MODERATION_ACTION_EXECUTION = 9,
    CHANNEL_CREATE = 10,
    CHANNEL_UPDATE = 11,
    CHANNEL_DELETE = 12,
    CHANNEL_PINS_UPDATE = 13,
    THREAD_CREATE = 14,
    THREAD_UPDATE = 15,
    THREAD_DELETE = 16,
    THREAD_LIST_SYNC = 17,
    THREAD_MEMBER_UPDATE = 18,
    THREAD_MEMBERS_UPDATE = 19,
    GUILD_CREATE = 20,
    GUILD_UPDATE = 21,
    GUILD_DELETE = 22,
    GUILD_BAN_ADD = 23,
    GUILD_BAN_REMOVE = 24,
    GUILD_EMOJIS_UPDATE = 25,
    GUILD_STICKERS_UPDATE = 26,
    GUILD_INTEGRATIONS_UPDATE = 27,
    GUILD_MEMBER_ADD = 28,
    GUILD_MEMBER_REMOVE = 29,
    GUILD_MEMBER_UPDATE = 30,
    GUILD_MEMBERS_CHUNK = 31,
    GUILD_ROLE_CREATE = 32,
    GUILD_ROLE_UPDATE = 33,
    GUILD_ROLE_DELETE = 34,
    GUILD_SCHEDULED_EVENT_CREATE = 35,
    GUILD_SCHEDULED_EVENT_UPDATE = 36,
    GUILD_SCHEDULED_EVENT_DELETE = 37,
    GUILD_SCHEDULED_EVENT_USER_ADD = 38,
    GUILD_SCHEDULED_EVENT_USER_REMOVE = 39,
    INTEGRATION_CREATE = 40,
    INTEGRATION_UPDATE = 41,
    INTEGRATION_DELETE = 42,
    INTERACTION_CREATE = 43,
    INVITE_CREATE = 44,
    INVITE_DELETE = 45,
    MESSAGE_CREATE = 46,
    MESSAGE_UPDATE = 47,
    MESSAGE_DELETE = 48,
    MESSAGE_DELETE_BULK = 49,
    MESSAGE_REACTION_ADD = 50,
    MESSAGE_REACTION_REMOVE = 51,
    MESSAGE_REACTION_REMOVE_ALL = 52,
    MESSAGE_REACTION_REMOVE_EMOJI = 53,
    PRESENCE_UPDATE = 54,
    STAGE_INSTANCE_CREATE = 55,
    STAGE_INSTANCE_DELETE = 56,
    STAGE_INSTANCE_UPDATE = 57,
    TYPING_START = 58,
    USER_UPDATE = 59,
    VOICE_STATE_UPDATE = 60,
    VOICE_SERVER_UPDATE = 61,
    WEBHOOKS_UPDATE = 62,
    MAX = 63,
};
pub const event_scheduler = enum(c_uint) {
    IGNORE = 0,
    MAIN_THREAD = 1,
    WORKER_THREAD = 2,
};

pub const APPLICATION = enum(c_int) {
    GATEWAY_PRESENCE = 1 << 12,
    GATEWAY_PRESENCE_LIMITED = 1 << 13,
    GATEWAY_GUILD_MEMBERS = 1 << 14,
    GATEWAY_GUILD_MEMBERS_LIMITED = 1 << 15,
    VERIFICATION_PENDING_GUILD_LIMIT = 1 << 16,
    EMBEDDED = 1 << 17,
    GATEWAY_MESSAGE_CONTENT = 1 << 18,
    GATEWAY_MESSAGE_CONTENT_LIMITED = 1 << 19,
};
pub const CHANNEL = enum(c_int) {
    PINNED = 1 << 1,
    REQUIRE_TAG = 1 << 4,
    HIDE_MEDIA_DOWNLOAD_OPTIONS = 1 << 5,
};

pub const MESSAGE = enum(c_int) {
    CROSSPOSTED = 1 << 0,
    IS_CROSSPOST = 1 << 1,
    SUPPRESS_EMBEDS = 1 << 2,
    SOURCE_MESSAGE_DELETED = 1 << 3,
    URGENT = 1 << 4,
    HAS_THREAD = 1 << 5,
    EPHEMERAL = 1 << 6,
    LOADING = 1 << 7,
    FAILED_TO_MENTION_SOME_ROLES_IN_THREAD = 1 << 8,
    SUPPRESS_NOTIFICATIONS = 1 << 12,
    IS_VOICE_MESSAGE = 1 << 13,
    HAS_COMPONENTS_V2 = 1 << 15,
};
pub const ATTACHMENT = enum(c_int) {
    IS_REMIX = 1 << 2,
};
pub const SYSTEM_SUPPRESS = enum(c_int) {
    JOIN_NOTIFICATIONS = 1 << 0,
    PREMIUM_NOTIFICATIONS = 1 << 1,
    GUILD_REMINDER_NOTIFICATIONS = 1 << 2,
    JOIN_NOTIFICATION_REPLIES = 1 << 3,
};
pub const USER = enum(c_int) {
    NONE = 0,
    STAFF = 1 << 0,
    PARTNER = 1 << 1,
    HYPESQUAD = 1 << 2,
    BUG_HUNTER_LEVEL_1 = 1 << 3,
    HYPESQUAD_ONLINE_HOUSE_1 = 1 << 6,
    HYPESQUAD_ONLINE_HOUSE_2 = 1 << 7,
    HYPESQUAD_ONLINE_HOUSE_3 = 1 << 8,
    PREMIUM_EARLY_SUPPORTER = 1 << 9,
    TEAM_PSEUDO_USER = 1 << 10,
    BUG_HUNTER_LEVEL_2 = 1 << 14,
    VERIFIED_BOT = 1 << 16,
    VERIFIED_DEVELOPER = 1 << 17,
    CERTIFIED_MODERATOR = 1 << 18,
    BOT_HTTP_INTERACTIONS = 1 << 19,
};
pub const GATEWAY = struct {
    pub const GUILDS: u64 = 1 << 0;
    pub const GUILD_MEMBERS: u64 = 1 << 1;
    pub const GUILD_BANS: u64 = 1 << 2;
    pub const GUILD_EMOJIS_AND_STICKERS: u64 = 1 << 3;
    pub const GUILD_INTEGRATIONS: u64 = 1 << 4;
    pub const GUILD_WEBHOOKS: u64 = 1 << 5;
    pub const GUILD_INVITES: u64 = 1 << 6;
    pub const GUILD_VOICE_STATES: u64 = 1 << 7;
    pub const GUILD_PRESENCES: u64 = 1 << 8;
    pub const GUILD_MESSAGES: u64 = 1 << 9;
    pub const GUILD_MESSAGE_REACTIONS: u64 = 1 << 10;
    pub const GUILD_MESSAGE_TYPING: u64 = 1 << 11;
    pub const DIRECT_MESSAGES: u64 = 1 << 12;
    pub const DIRECT_MESSAGE_REACTIONS: u64 = 1 << 13;
    pub const DIRECT_MESSAGE_TYPING: u64 = 1 << 14;
    pub const MESSAGE_CONTENT: u64 = 1 << 15;
    pub const GUILD_SCHEDULED_EVENTS: u64 = 1 << 16;
    pub const AUTO_MODERATION_CONFIGURATION: u64 = 1 << 20;
    pub const AUTO_MODERATION_EXECUTION: u64 = 1 << 21;
};
pub const ACTIVITY = enum(c_int) {
    INSTANCE = 1 << 0,
    JOIN = 1 << 1,
    SPECTATE = 1 << 2,
    JOIN_REQUEST = 1 << 3,
    SYNC = 1 << 4,
    PLAY = 1 << 5,
    PARTY_PRIVACY_FRIENDS = 1 << 6,
    PARTY_PRIVACY_VOICE_CHANNEL = 1 << 7,
    EMBEDDED = 1 << 8,
};
pub const PERM = enum(c_int) {
    CREATE_INSTANT_INVITE = 1 << 0,
    KICK_MEMBERS = 1 << 1,
    BAN_MEMBERS = 1 << 2,
    ADMINISTRATOR = 1 << 3,
    MANAGE_CHANNELS = 1 << 4,
    MANAGE_GUILD = 1 << 5,
    ADD_REACTIONS = 1 << 6,
    VIEW_AUDIT_LOG = 1 << 7,
    PRIORITY_SPEAKER = 1 << 8,
    STREAM = 1 << 9,
    VIEW_CHANNEL = 1 << 10,
    SEND_MESSAGES = 1 << 11,
    SEND_TTS_MESSAGES = 1 << 12,
    MANAGE_MESSAGES = 1 << 13,
    EMBED_LINKS = 1 << 14,
    ATTACH_FILES = 1 << 15,
    READ_MESSAGE_HISTORY = 1 << 16,
    MENTION_EVERYONE = 1 << 17,
    USE_EXTERNAL_EMOJIS = 1 << 18,
    VIEW_GUILD_INSIGHTS = 1 << 19,
    CONNECT = 1 << 20,
    SPEAK = 1 << 21,
    MUTE_MEMBERS = 1 << 22,
    DEAFEN_MEMBERS = 1 << 23,
    MOVE_MEMBERS = 1 << 24,
    USE_VAD = 1 << 25,
    CHANGE_NICKNAME = 1 << 26,
    MANAGE_NICKNAMES = 1 << 27,
    MANAGE_ROLES = 1 << 28,
    MANAGE_WEBHOOKS = 1 << 29,
    MANAGE_EMOJIS_AND_STICKERS = 1 << 30,
    USE_APPLICATION_COMMANDS = 1 << 31,
    REQUEST_TO_SPEAK = 1 << 32,
    MANAGE_EVENTS = 1 << 33,
    MANAGE_THREADS = 1 << 34,
    CREATE_PUBLIC_THREADS = 1 << 35,
    CREATE_PRIVATE_THREADS = 1 << 36,
    USE_EXTERNAL_STICKERS = 1 << 37,
    SEND_MESSAGES_IN_THREADS = 1 << 38,
    START_EMBEDDED_ACTIVITIES = 1 << 39,
    MODERATE_MEMBERS = 1 << 40,
};
pub const VOICE = enum(c_int) {
    MICROPHONE = 1 << 0,
    SOUNDSHARE = 1 << 1,
    PRIORITY = 1 << 2,
};
pub const ErrorCode = enum(i32) {
    OK = 0,
    MALFORMED_PAYLOAD = -12,
    FULL_WORKER = -11,
    UNAVAILABLE = -10, // Same as RESOURCE_UNAVAILABLE
    OWNERSHIP = -9, // Same as RESOURCE_OWNERSHIP
    GLOBAL_INIT = -8,
    CURLM_INTERNAL = -7,
    CURLE_INTERNAL = -6,
    BAD_JSON = -5,
    BAD_PARAMETER = -4,
    UNUSUAL_HTTP_CODE = -3,
    CURL_NO_RESPONSE = -2,
    HTTP_CODE = -1,
    PENDING = 1,
    DISCORD_JSON_CODE = 100,
    DISCORD_BAD_AUTH = 101,
    DISCORD_RATELIMIT = 102,
    DISCORD_CONNECTION = 103,

    pub const Error = error{
        MalformedPayload,
        FullWorker,
        Unavailable,
        Ownership,
        GlobalInit,
        CurlmInternal,
        CurleInternal,
        BadJson,
        BadParameter,
        UnusualHttpCode,
        CurlNoResponse,
        HttpCode,
        DiscordJsonCode,
        DiscordBadAuth,
        DiscordRatelimit,
        DiscordConnection,
    };

    pub fn log(self: @This(), ctx: ?[]const u8) @This() {
        self.toError() catch return self;
        @import("std").log.err("{t}{s}{s}", .{ self, if (ctx != null) " at " else "", ctx orelse "" });
        return self;
    }

    pub fn toError(self: @This()) Error!void {
        return switch (self) {
            .MALFORMED_PAYLOAD => error.MalformedPayload,
            .FULL_WORKER => error.FullWorker,
            .UNAVAILABLE => error.Unavailable,
            .OWNERSHIP => error.Ownership,
            .GLOBAL_INIT => error.GlobalInit,
            .CURLM_INTERNAL => error.CurlmInternal,
            .CURLE_INTERNAL => error.CurleInternal,
            .BAD_JSON => error.BadJson,
            .BAD_PARAMETER => error.BadParameter,
            .UNUSUAL_HTTP_CODE => error.UnusualHttpCode,
            .CURL_NO_RESPONSE => error.CurlNoResponse,
            .HTTP_CODE => error.HttpCode,
            .PENDING => {},
            .DISCORD_JSON_CODE => error.DiscordJsonCode,
            .DISCORD_BAD_AUTH => error.DiscordBadAuth,
            .DISCORD_RATELIMIT => error.DiscordRatelimit,
            .DISCORD_CONNECTION => error.DiscordConnection,
            .OK => {},
        };
    }
};

extern fn discord_init(token: [*:0]const u8) ?Client;
pub const init = discord_init;

pub const Client = *opaque {
    pub const Return = extern struct {
        done_: ?*const fn (client: Client, resp: *DiscordResponse) void = null,
        sync: bool = false,
    };

    extern fn discord_cleanup(client: Client) void;
    pub const cleanup = discord_cleanup;

    extern fn discord_set_data(client: Client, data: *anyopaque) ?*anyopaque;
    pub fn setData(client: Client, comptime T: type, data: *T) void {
        _ = discord_set_data(client, @ptrCast(@alignCast(data)));
    }

    extern fn discord_get_data(client: Client) ?*anyopaque;
    pub fn getData(client: Client, comptime T: type) ?*T {
        return @ptrCast(@alignCast(discord_get_data(client)));
    }

    extern fn discord_return_error(client: Client, err: [*:0]const u8, code: ErrorCode) ErrorCode;
    pub const returnError = discord_return_error;

    extern fn discord_strerror(code: ErrorCode, client: Client) [*:0]const u8;
    pub const strerror = discord_strerror;

    extern fn discord_config_init(config_file: [*:0]const u8) Client;
    pub const configInit = discord_config_init;

    extern fn discord_run(client: Client) ErrorCode;
    pub const run = discord_run;

    extern fn discord_get_user(client: Client, user_id: u64snowflake, ret: ?*User.Return) ErrorCode;
    pub const getUser = discord_get_user;

    extern fn discord_create_guild_application_command(client: Client, application_id: u64snowflake, guild_id: u64snowflake, params: *const CreateGuildApplicationCommand, ret: ?*ApplicationCommand.Return) ErrorCode;
    pub const createGuildApplicationCommand = discord_create_guild_application_command;

    extern fn discord_create_global_application_command(client: Client, application_id: u64snowflake, params: *const CreateGlobalApplicationCommand, ret: ?*CreateGlobalApplicationCommand.Return) ErrorCode;
    pub const createGlobalApplicationCommand = discord_create_global_application_command;

    extern fn discord_create_message(client: Client, channel_id: u64snowflake, params: *const Message.Create, ret: ?*Message.Return) ErrorCode;
    pub const createMessage = discord_create_message;

    extern fn discord_create_interaction_response(client: Client, interaction_id: u64snowflake, interaction_token: [*:0]const u8, params: *const Interaction.Response, ret: ?*Interaction.Response.Return) ErrorCode;
    pub const createInteractionResponse = discord_create_interaction_response;

    extern fn discord_request_guild_members(client: Client, request: ?*RequestGuildMembers) void;
    pub const requestGuildMembers = discord_request_guild_members;

    extern fn discord_update_voice_state(client: Client, update: ?*UpdateVoiceState) void;
    pub const updateVoiceState = discord_update_voice_state;

    extern fn discord_update_presence(client: Client, presence: ?*presence_update) void;
    pub const updatePresence = discord_update_presence;

    extern fn discord_set_presence(client: Client, presence: ?*presence_update) void;
    pub const setPresence = discord_set_presence;

    extern fn discord_set_event_scheduler(client: Client, callback: discord_ev_scheduler) void;
    pub const setEventScheduler = discord_set_event_scheduler;

    extern fn discord_add_intents(client: Client, code: u64) void;
    pub const addIntents = discord_add_intents;

    extern fn discord_remove_intents(client: Client, code: u64) void;
    pub const removeIntents = discord_remove_intents;

    extern fn discord_set_prefix(client: Client, prefix: [*c]const u8) void;
    pub const setPrefix = discord_set_prefix;

    extern fn discord_set_on_command(client: Client, command: [*:0]const u8, callback: ?*const fn (client: Client, event: *const Message) callconv(.c) void) void;
    pub const setOnCommand = discord_set_on_command;

    extern fn discord_set_on_commands(client: Client, commands: [*]const [*:0]const u8, amount: c_int, callback: ?*const fn (client: Client, event: *const Message) callconv(.c) void) void;
    pub const setOnCommands = discord_set_on_commands;

    extern fn discord_set_next_wakeup(client: Client, delay: i64) void;
    pub const setNextWakeup = discord_set_next_wakeup;

    extern fn discord_set_on_wakeup(client: Client, callback: ?*const fn (client: Client) callconv(.c) void) void;
    pub const setOnWakeup = discord_set_on_wakeup;

    extern fn discord_set_on_idle(client: Client, callback: ?*const fn (client: Client) callconv(.c) void) void;
    pub const setOnIdle = discord_set_on_idle;

    extern fn discord_set_on_cycle(client: Client, callback: ?*const fn (client: Client) callconv(.c) void) void;
    pub const setOnCycle = discord_set_on_cycle;

    extern fn discord_set_on_ready(client: Client, callback: ?*const fn (client: Client, event: *const Ready) callconv(.c) void) void;
    pub const setOnReady = discord_set_on_ready;

    extern fn discord_set_on_application_command_permissions_update(client: Client, callback: ?*const fn (client: Client, event: *const application_command_permissions) callconv(.c) void) void;
    pub const setOnApplicationCommandPermissionsUpdate = discord_set_on_application_command_permissions_update;

    extern fn discord_create_reaction(client: Client, channel_id: u64snowflake, message_id: u64snowflake, emoji_id: u64snowflake, emoji_name: ?[*:0]const u8, ret: ?*Return) ErrorCode;
    pub const createReaction = discord_create_reaction;

    extern fn discord_set_on_auto_moderation_rule_create(client: Client, callback: ?*const fn (client: Client, event: *const auto_moderation_rule) callconv(.c) void) void;
    pub const setOnAutoModerationRuleCreate = discord_set_on_auto_moderation_rule_create;

    extern fn discord_set_on_auto_moderation_rule_update(client: Client, callback: ?*const fn (client: Client, event: *const auto_moderation_rule) callconv(.c) void) void;
    pub const setOnAutoModerationRuleUpdate = discord_set_on_auto_moderation_rule_update;

    extern fn discord_set_on_auto_moderation_rule_delete(client: Client, callback: ?*const fn (client: Client, event: *const auto_moderation_rule) callconv(.c) void) void;
    pub const setOnAutoModerationRuleDelete = discord_set_on_auto_moderation_rule_delete;

    extern fn discord_set_on_auto_moderation_action_execution(client: Client, callback: ?*const fn (client: Client, event: *const auto_moderation_action_execution) callconv(.c) void) void;
    pub const setOnAutoModerationActionExecution = discord_set_on_auto_moderation_action_execution;

    extern fn discord_set_on_channel_create(client: Client, callback: ?*const fn (client: Client, event: *const Channel) callconv(.c) void) void;
    pub const setOnChannelCreate = discord_set_on_channel_create;

    extern fn discord_set_on_channel_update(client: Client, callback: ?*const fn (client: Client, event: *const Channel) callconv(.c) void) void;
    pub const setOnChannelUpdate = discord_set_on_channel_update;

    extern fn discord_set_on_channel_delete(client: Client, callback: ?*const fn (client: Client, event: *const Channel) callconv(.c) void) void;
    pub const setOnChannelDelete = discord_set_on_channel_delete;

    extern fn discord_set_on_channel_pins_update(client: Client, callback: ?*const fn (client: Client, event: *const channel_pins_update) callconv(.c) void) void;
    pub const setOnChannelPinsUpdate = discord_set_on_channel_pins_update;

    extern fn discord_set_on_thread_create(client: Client, callback: ?*const fn (client: Client, event: *const Channel) callconv(.c) void) void;
    pub const setOnThreadCreate = discord_set_on_thread_create;

    extern fn discord_set_on_thread_update(client: Client, callback: ?*const fn (client: Client, event: *const Channel) callconv(.c) void) void;
    pub const setOnThreadUpdate = discord_set_on_thread_update;

    extern fn discord_set_on_thread_delete(client: Client, callback: ?*const fn (client: Client, event: *const Channel) callconv(.c) void) void;
    pub const setOnThreadDelete = discord_set_on_thread_delete;

    extern fn discord_set_on_thread_list_sync(client: Client, callback: ?*const fn (client: Client, event: *const thread_list_sync) callconv(.c) void) void;
    pub const setOnThreadListSync = discord_set_on_thread_list_sync;

    extern fn discord_set_on_thread_member_update(client: Client, callback: ?*const fn (client: Client, event: *const thread_member) callconv(.c) void) void;
    pub const setOnThreadMemberUpdate = discord_set_on_thread_member_update;

    extern fn discord_set_on_thread_members_update(client: Client, callback: ?*const fn (client: Client, event: *const thread_members_update) callconv(.c) void) void;
    pub const setOnThreadMembersUpdate = discord_set_on_thread_members_update;

    extern fn discord_set_on_guild_create(client: Client, callback: ?*const fn (client: Client, event: *const guild) callconv(.c) void) void;
    pub const setOnGuildCreate = discord_set_on_guild_create;

    extern fn discord_set_on_guild_update(client: Client, callback: ?*const fn (client: Client, event: *const guild) callconv(.c) void) void;
    pub const setOnGuildUpdate = discord_set_on_guild_update;

    extern fn discord_set_on_guild_delete(client: Client, callback: ?*const fn (client: Client, event: *const guild) callconv(.c) void) void;
    pub const setOnGuildDelete = discord_set_on_guild_delete;

    extern fn discord_set_on_guild_ban_add(client: Client, callback: ?*const fn (client: Client, event: *const guild_ban_add) callconv(.c) void) void;
    pub const setOnGuildBanAdd = discord_set_on_guild_ban_add;

    extern fn discord_set_on_guild_ban_remove(client: Client, callback: ?*const fn (client: Client, event: *const guild_ban_remove) callconv(.c) void) void;
    pub const setOnGuildBanRemove = discord_set_on_guild_ban_remove;

    extern fn discord_set_on_guild_emojis_update(client: Client, callback: ?*const fn (client: Client, event: *const guild_emojis_update) callconv(.c) void) void;
    pub const setOnGuildEmojisUpdate = discord_set_on_guild_emojis_update;

    extern fn discord_set_on_guild_stickers_update(client: Client, callback: ?*const fn (client: Client, event: *const guild_stickers_update) callconv(.c) void) void;
    pub const setOnGuildStickersUpdate = discord_set_on_guild_stickers_update;

    extern fn discord_set_on_guild_integrations_update(client: Client, callback: ?*const fn (client: Client, event: *const guild_integrations_update) callconv(.c) void) void;
    pub const setOnGuildIntegrationsUpdate = discord_set_on_guild_integrations_update;

    extern fn discord_set_on_guild_member_add(client: Client, callback: ?*const fn (client: Client, event: *const guild_member) callconv(.c) void) void;
    pub const setOnGuildMemberAdd = discord_set_on_guild_member_add;

    extern fn discord_set_on_guild_member_update(client: Client, callback: ?*const fn (client: Client, event: *const guild_member_update) callconv(.c) void) void;
    pub const setOnGuildMemberUpdate = discord_set_on_guild_member_update;

    extern fn discord_set_on_guild_member_remove(client: Client, callback: ?*const fn (client: Client, event: *const guild_member_remove) callconv(.c) void) void;
    pub const setOnGuildMemberRemove = discord_set_on_guild_member_remove;

    extern fn discord_set_on_guild_members_chunk(client: Client, callback: ?*const fn (client: Client, event: *const guild_members_chunk) callconv(.c) void) void;
    pub const setOnGuildMembersChunk = discord_set_on_guild_members_chunk;

    extern fn discord_set_on_guild_role_create(client: Client, callback: ?*const fn (client: Client, event: *const guild_role_create) callconv(.c) void) void;
    pub const setOnGuildRoleCreate = discord_set_on_guild_role_create;

    extern fn discord_set_on_guild_role_update(client: Client, callback: ?*const fn (client: Client, event: *const guild_role_update) callconv(.c) void) void;
    pub const setOnGuildRoleUpdate = discord_set_on_guild_role_update;

    extern fn discord_set_on_guild_role_delete(client: Client, callback: ?*const fn (client: Client, event: *const guild_role_delete) callconv(.c) void) void;
    pub const setOnGuildRoleDelete = discord_set_on_guild_role_delete;

    extern fn discord_set_on_guild_scheduled_event_create(client: Client, callback: ?*const fn (client: Client, event: *const guild_scheduled_event) callconv(.c) void) void;
    pub const setOnGuildScheduledEventCreate = discord_set_on_guild_scheduled_event_create;

    extern fn discord_set_on_guild_scheduled_event_update(client: Client, callback: ?*const fn (client: Client, event: *const guild_scheduled_event) callconv(.c) void) void;
    pub const setOnGuildScheduledEventUpdate = discord_set_on_guild_scheduled_event_update;

    extern fn discord_set_on_guild_scheduled_event_delete(client: Client, callback: ?*const fn (client: Client, event: *const guild_scheduled_event) callconv(.c) void) void;
    pub const setOnGuildScheduledEventDelete = discord_set_on_guild_scheduled_event_delete;

    extern fn discord_set_on_guild_scheduled_event_user_add(client: Client, callback: ?*const fn (client: Client, event: *const guild_scheduled_event_user_add) callconv(.c) void) void;
    pub const setOnGuildScheduledEventUserAdd = discord_set_on_guild_scheduled_event_user_add;

    extern fn discord_set_on_guild_scheduled_event_user_remove(client: Client, callback: ?*const fn (client: Client, event: *const guild_scheduled_event_user_remove) callconv(.c) void) void;
    pub const setOnGuildScheduledEventUserRemove = discord_set_on_guild_scheduled_event_user_remove;

    extern fn discord_set_on_integration_create(client: Client, callback: ?*const fn (client: Client, event: *const integration) callconv(.c) void) void;
    pub const setOnIntegrationCreate = discord_set_on_integration_create;

    extern fn discord_set_on_integration_update(client: Client, callback: ?*const fn (client: Client, event: *const integration) callconv(.c) void) void;
    pub const setOnIntegrationUpdate = discord_set_on_integration_update;

    extern fn discord_set_on_integration_delete(client: Client, callback: ?*const fn (client: Client, event: *const integration_delete) callconv(.c) void) void;
    pub const setOnIntegrationDelete = discord_set_on_integration_delete;

    extern fn discord_set_on_interaction_create(client: Client, callback: ?*const fn (client: Client, event: *const Interaction) callconv(.c) void) void;
    pub const setOnInteractionCreate = discord_set_on_interaction_create;

    extern fn discord_set_on_invite_create(client: Client, callback: ?*const fn (client: Client, event: *const invite_create) callconv(.c) void) void;
    pub const setOnInviteCreate = discord_set_on_invite_create;

    extern fn discord_set_on_invite_delete(client: Client, callback: ?*const fn (client: Client, event: *const invite_delete) callconv(.c) void) void;
    pub const setOnInviteDelete = discord_set_on_invite_delete;

    extern fn discord_set_on_message_create(client: Client, callback: ?*const fn (client: Client, event: *const Message) callconv(.c) void) void;
    pub const setOnMessageCreate = discord_set_on_message_create;

    extern fn discord_set_on_message_update(client: Client, callback: ?*const fn (client: Client, event: *const Message) callconv(.c) void) void;
    pub const setOnMessageUpdate = discord_set_on_message_update;

    extern fn discord_set_on_message_delete(client: Client, callback: ?*const fn (client: Client, event: *const message_delete) callconv(.c) void) void;
    pub const setOnMessageDelete = discord_set_on_message_delete;

    extern fn discord_set_on_message_delete_bulk(client: Client, callback: ?*const fn (client: Client, event: *const message_delete_bulk) callconv(.c) void) void;
    pub const setOnMessageDeleteBulk = discord_set_on_message_delete_bulk;

    extern fn discord_set_on_message_reaction_add(client: Client, callback: ?*const fn (client: Client, event: *const message_reaction.Add) callconv(.c) void) void;
    pub const setOnMessageReactionAdd = discord_set_on_message_reaction_add;

    extern fn discord_set_on_message_reaction_remove(client: Client, callback: ?*const fn (client: Client, event: *const message_reaction.Remove) callconv(.c) void) void;
    pub const setOnMessageReactionRemove = discord_set_on_message_reaction_remove;

    extern fn discord_set_on_message_reaction_remove_all(client: Client, callback: ?*const fn (client: Client, event: *const message_reaction.RemoveAll) callconv(.c) void) void;
    pub const setOnMessageReactionRemoveAll = discord_set_on_message_reaction_remove_all;

    extern fn discord_set_on_message_reaction_remove_emoji(client: Client, callback: ?*const fn (client: Client, event: *const message_reaction.RemoveEmoji) callconv(.c) void) void;
    pub const setOnMessageReactionRemoveEmoji = discord_set_on_message_reaction_remove_emoji;

    extern fn discord_set_on_presence_update(client: Client, callback: ?*const fn (client: Client, event: *const presence_update) callconv(.c) void) void;
    pub const setOnPresenceUpdate = discord_set_on_presence_update;

    extern fn discord_set_on_stage_instance_create(client: Client, callback: ?*const fn (client: Client, event: *const stage_instance) callconv(.c) void) void;
    pub const setOnStageInstanceCreate = discord_set_on_stage_instance_create;

    extern fn discord_set_on_stage_instance_update(client: Client, callback: ?*const fn (client: Client, event: *const stage_instance) callconv(.c) void) void;
    pub const setOnStageInstanceUpdate = discord_set_on_stage_instance_update;

    extern fn discord_set_on_stage_instance_delete(client: Client, callback: ?*const fn (client: Client, event: *const stage_instance) callconv(.c) void) void;
    pub const setOnStageInstanceDelete = discord_set_on_stage_instance_delete;

    extern fn discord_set_on_typing_start(client: Client, callback: ?*const fn (client: Client, event: *const typing_start) callconv(.c) void) void;
    pub const setOnTypingStart = discord_set_on_typing_start;

    extern fn discord_set_on_user_update(client: Client, callback: ?*const fn (client: Client, event: *const User) callconv(.c) void) void;
    pub const setOnUserUpdate = discord_set_on_user_update;

    extern fn discord_set_on_voice_state_update(client: Client, callback: ?*const fn (client: Client, event: *const voice_state) callconv(.c) void) void;
    pub const setOnVoiceStateUpdate = discord_set_on_voice_state_update;

    extern fn discord_set_on_voice_server_update(client: Client, callback: ?*const fn (client: Client, event: *const voice_server_update) callconv(.c) void) void;
    pub const setOnVoiceServerUpdate = discord_set_on_voice_server_update;

    extern fn discord_set_on_webhooks_update(client: Client, callback: ?*const fn (client: Client, event: *const webhooks_update) callconv(.c) void) void;
    pub const setOnWebhooksUpdate = discord_set_on_webhooks_update;
};
