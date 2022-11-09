class BookCommentsController < ApplicationController

 def create
    book = Book.find(params[:book_id])
    @comment = current_user.book_comments.new(book_comment_params)
    @comment.book_id = book.id
    @comment.save
    #わたす値→booksのshowページからrenderしてるので、同じ値渡せば良い。
    #create.js.erbで@books @book_commentを渡しているため、book_comments_controllerでこの値を定義する必要がある。
 end

 def destroy
    @book = Book.find(params[:book_id])
    @comment = BookComment.find_by(id: params[:id], book_id: params[:book_id])
    @comment.destroy
    #わたす値→booksのshowページからrenderしてるので、同じ値渡せば良い。
    #destroy.js.erbで@books @book_commentを渡しているため、book_comments_controllerでこの値を定義。
 end

  private

  def book_comment_params
    params.require(:book_comment).permit(:comment)
  end

end

# redirect_back(fallback_location: root_path)→削除
#リダイレクト先を削除→リダイレクト先がない、かつJavaScriptリクエストという状況になる
# →createアクション実行後は、create.js.erbファイルを、destroyアクション実行後はdestroy.js.erbファイルを探すようになる。