# name: simple-flags
# version: 1.1.0
# authors: boyned/Kampfkarren, buildthomas

# enabled_site_setting :simple_flags_enabled

after_initialize do
  require_dependency "category"

  Site.preloaded_category_custom_fields << "flags_to_hide_post"

  register_category_custom_field_type("flags_to_hide_post", :integer)

  add_to_serializer(:basic_category, :flags_to_hide_post) { object.flags_to_hide_post }

  class ::Category
    def flags_to_hide_post
      self.custom_fields["flags_to_hide_post"]
    end
  end

  module PostActionCreatorInterceptor

    def auto_hide_if_needed
      return super unless SiteSetting.simple_flags_enabled
      
      return if @post.hidden?
      return if !@created_by.staff? && @post.user&.staff?

      threshold = @post.topic.category&.flags_to_hide_post
      threshold = SiteSetting.default_flags_required unless threshold && threshold > 0

      count = PostAction
        .where(post_id: @post.id)
        .where(post_action_type_id: PostActionType.notify_flag_type_ids)
        .where(deleted_at: nil)
        .where(disagreed_at: nil)
        .where(deferred_at: nil)
        .count

      @post.hide!(@post_action_type_id) if count >= threshold
    end

  end

  PostActionCreator.send(:prepend, PostActionCreatorInterceptor)

end
