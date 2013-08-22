# -*- encoding : utf-8 -*-
#
# The Rails Controller for model Page
class PagesController < ApplicationController

  # Roles which can create pages
  # ruby 2.0 only # PAGE_CREATOR_ROLES = %i( admin author editor maintainer )
  PAGE_CREATOR_ROLES = [ :admin, :author, :editor, :maintainer ]

  # Roles which can edit pages
  # ruby 2.0 only #PAGE_EDITOR_ROLES  = %i( admin editor maintainer )
  PAGE_EDITOR_ROLES  = [ :admin, :editor, :maintainer ]
  helper_method :is_page_editor?

  # Roles which can delete pages
  # ruby 2.0 only #PAGE_TERMINATOR_ROLES  = %i( admin maintainer )
  PAGE_TERMINATOR_ROLES  = [ :admin, :maintainer ]


  rescue_from PageNotFoundError, with: :render_not_found

  # Loading all *.md-files from project's root into Page-store
  before_filter :refresh_md_files

  # Load @page if param :id is present
  before_filter :load_resource

  # Redirect with access denied if action is not allowed
  before_filter :authorize_creators, only: [ :new, :create ]
  before_filter :authorize_editors,  only: [ :edit, :update ]
  before_filter :authorize_terminators, only: [ :destroy ]


  # TODO: Fix 0/false 1/true in Store - needs Datatype!
  # GET /pages
  def index
    @pages = Page.where( draft: false )
    @pages += Page.where( draft: "0" )
    @pages += Page.where( draft: true ) if is_page_editor?
    @pages += Page.where( draft: "1" ) if is_page_editor?
  end

  # GET /pages/:id
  # @raise [PageNotFoundError] if page doesn't exist
  def show
    raise PageNotFoundError.new(params[:id]) unless @page
  end

  # GET /pages/new
  def new
    @page = Page.new
  end

  # POST /pages/create
  def create
    @page = Page.create( params[:page] )
    if @page.valid_without_errors?
      redirect_to page_path( @page )
    else
      flash.now[:alert]= t(:could_not_be_saved, what: t(:page))
      render :new
    end
  end

  # GET /pages/:id/edit
  def edit
  end

  # PUT /pages/:id
  def update
    if @page.update_attributes( params[:page] )
      redirect_to pages_path, notice: t(:page_successfully_updated)
    else
      render :edit
    end
  end

  # DELETE /pages/:id
  def destroy
    @page.delete 
    redirect_to pages_path, notice: t(:page_deleted, title: @page.title)
  end


  # Update Sort Order
  # POST /pages/update_order
  def update_order
    update_positions params[:sorted_ids]
    render nothing: true
  end


  private

  def is_page_editor?
    has_roles?(PagesController::PAGE_EDITOR_ROLES)
  end

  def update_positions ordered_ids
    ordered_ids.each_with_index do |id, idx|
      p = Page.find(id.gsub(/^page-/,''))
      p.update_attributes( { position: idx + 1 } ) if p
    end
  end

  def refresh_md_files
    Dir[md_files_wildcards].each do |file|
      _title = title_of_md_file file
      page = Page.find(_title) || Page.create( title: _title.upcase, draft: false )
      page.body = File.read(file)
      page.save
    end
  end

  def md_files_wildcards
    File.join(Rails.root,'*.md')
  end

  def title_of_md_file _file
    File.basename(_file, '.md')
  end

  def render_not_found
    flash[:alert]=t(:page_does_not_exists, title: params[:id])
    @pages = Page.all
    render :index, status: :not_found
  end

  def authorize_creators
    redirect_back_or_to pages_path, alert: t(:access_denied) unless has_roles?( PAGE_CREATOR_ROLES )
  end

  def authorize_editors
    redirect_back_or_to page_path(params[:id]), alert: t(:access_denied) unless has_roles?( PAGE_EDITOR_ROLES )
  end

  def authorize_terminators
    redirect_back_or_to pages_path, alert: t(:access_denied) unless has_roles?( PAGE_TERMINATOR_ROLES )
  end

  def load_resource
    @page ||= Page.find(params[:id]) if params[:id].present?
  end
  
end
